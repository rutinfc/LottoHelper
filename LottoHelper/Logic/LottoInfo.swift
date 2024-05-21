//
//  LottoInfo.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import SwiftUI
import SwiftData
import Combine
import CoreData

struct LottoInfo {
    
    static let maxCount = 6
    static let numberList = Array(1...46)
    
    static func randomNumbers(count: Int = LottoInfo.maxCount, exception: [Int]? = nil) -> Set<Int> {
        
        var numbers = Set<Int>()
        
        if let list = exception {
            numbers.formUnion(list)
        }
        
        while numbers.count < count {
            let number = Int.random(in: (1...46))
            if numbers.contains(number) {
                continue
            }
            numbers.insert(number)
        }
        
        return numbers
    }
    
    static let analyzer = WinsNumberAsyncAnalyzer()
    
    actor WinsNumberAsyncAnalyzer {
        
        private nonisolated lazy var numbersCount = {
            CurrentValueSubject<[Int: Int], Never>([Int: Int]())
        }()
        
        private nonisolated lazy var avgNumberPercent = {
            CurrentValueSubject<LottoInfo.Analyze.AvgModel, Never>(LottoInfo.Analyze.AvgModel(totalPercent: 0, numbers: [LottoInfo.Analyze.AvgNumberModel]()))
        }()
        
        nonisolated var numberCountPublisher: AnyPublisher<[Int: Int], Never> {
            self.numbersCount.dropFirst().eraseToAnyPublisher()
        }
        
        nonisolated var avgNumberPercentPublisher: AnyPublisher<LottoInfo.Analyze.AvgModel, Never> {
            self.avgNumberPercent
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        nonisolated func execute() {
            Task {
                await self.progress()
            }
        }
        
        func progress() async {
            let desc = FetchDescriptor<WinNumbers>()
            do {
                let list = try Container.shared.privateContext.fetch(desc)
                await self.reload(winNumbers: list)
            }  catch {
                fatalError(String(describing: error))
            }
        }
        
        func reload(winNumbers: [WinNumbers]) async {
            
            let result = winNumbers
                .flatMap({ $0.numbers })
                .reduce(into: [:]) { $0[$1, default: 0] += 1 }
            
            self.numbersCount.send(result)
            
            let lastRound = await Container.shared.lastRoundAsync()
            var totalRate: Float = 0
            
            let avgNumberPercent = LottoInfo.numberList.compactMap { number in
                let count = result[number] ?? 0
                var rate: Float = 0
                if count > 0 {
                    rate = Float(count) / Float(lastRound)
                }
                totalRate += Float(count)
                return LottoInfo.Analyze.AvgNumberModel(number: number, count: count, percent: rate * 100)
            }
            
            totalRate = (totalRate / Float(LottoInfo.numberList.count) / Float(lastRound)) * 100

            let avg = LottoInfo.Analyze.AvgModel(totalPercent: totalRate, numbers: avgNumberPercent)
            self.avgNumberPercent.send(avg)
        }
        
        func partialWins(numbers: [Int]) -> [WinNumbers] {
            
            return [WinNumbers(round: 10, numbers: numbers, plus: 4)]
        }
    }
    
    final class Container {
        
        private var cancelBag = Set<AnyCancellable>()
        
        static let shared = Container()
        
        var modelContainer: ModelContainer = {
            let schema = Schema([
                WinNumbers.self,
                CheckNumbers.self,
                NumbersTotalCount.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
        
        var changePublisher: AnyPublisher<[String], Never> = {
            let publisher = NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)
                .compactMap({$0.userInfo})
            
            let update = publisher.compactMap({ $0[NSUpdatedObjectsKey] as? Set<NSManagedObject> })
            let delete = publisher.compactMap({ $0[NSDeletedObjectsKey] as? Set<NSManagedObject> })
            let insert = publisher.compactMap({ $0[NSInsertedObjectsKey] as? Set<NSManagedObject> })
            let refreshed = publisher.compactMap({ $0[NSRefreshedObjectsKey] as? Set<NSManagedObject> })
            
            return Publishers.Merge4(update, delete, insert, refreshed)
                .debounce(for: 0.1, scheduler: RunLoop.main)
                .compactMap({ $0.compactMap({ $0.entity.name }) })
                .compactMap({ Array(Set($0)) })
                .eraseToAnyPublisher()
        }()
        
        @MainActor var mainContext: ModelContext {
            self.modelContainer.mainContext
        }
        
        fileprivate lazy var privateContext: ModelContext = {
            ModelContext(modelContainer)
        }()
        
        @MainActor var lastRound: Int {
            let desc = FetchDescriptor<WinNumbers>()
            var round: Int = 0
            do {
                round = try Container.shared.mainContext.fetchCount(desc)
            } catch {
                fatalError(String(describing: error))
            }
            return round
        }
        
        init() {
            
            self.changePublisher.sink { entityNames in
                
                if entityNames.contains(where: { $0 == "WinNumbers" }) {
                    LottoInfo.analyzer.execute()
                }
                
            }.store(in: &self.cancelBag)
        }
        
        func lastRoundAsync() async -> Int {
            let desc = FetchDescriptor<WinNumbers>()
            var round: Int = 0
            do {
                round = try Container.shared.privateContext.fetchCount(desc)
            } catch {
                fatalError(String(describing: error))
            }
            return round
        }
    }
    
    final class CheckIntent {
        
        @MainActor var lastRound: Int {
            Container.shared.lastRound
        }
        
        @MainActor func save(round: Int, numbers: [Int]) {
            
            let item = CheckNumbers(round: round, numbers: numbers, timestamp: Date())
            
            Task {
                let context = Container.shared.privateContext
                
                context.insert(item)
            }
        }
    }
    
    @MainActor
    final class Analyze: ObservableObject {
        
        struct AvgModel: Hashable {
            var totalPercent: Float
            var numbers: [AvgNumberModel]
        }
        
        struct AvgNumberModel: Identifiable, Hashable {
            
            var id: Int {
                return number
            }
            
            let number: Int
            let count: Int
            let percent: Float
        }
        
        @Published var avgInfo = AvgModel(totalPercent: 0, numbers: [AvgNumberModel]())
        
        private var cancelBag = Set<AnyCancellable>()
        
        private var current: Task<(), Error>?
        
        init() {
            
            LottoInfo.analyzer.avgNumberPercentPublisher.sink { value in
                self.avgInfo = value
            }.store(in: &self.cancelBag)
        }
        
        @MainActor func reload() {
            LottoInfo.analyzer.execute()
        }
        
        func partialWinNumbers(numbers: [Int]) -> AnyPublisher<[WinNumbers], Never> {
            
            self.current?.cancel()
            
            let publisher = PassthroughSubject<[WinNumbers], Never>()
            
            self.current = Task.detached {
                let result = await LottoInfo.analyzer.partialWins(numbers: numbers)
                publisher.send(result)
            }
            
            return publisher.eraseToAnyPublisher()
        }
    }
    
    final class WinIntent {
        
        @MainActor func add() {
            
            Container.shared.add()
        }
        
        @MainActor func removeAll() {
            
            Container.shared.removeAll()
        }
        
        @MainActor func createDummy(rounds: Int) {
            
            Container.shared.createDummy(rounds: rounds)
        }
    }
}

fileprivate extension LottoInfo.Container {
    
    func getDummyNumbers(rounds: Int) async -> [WinNumbers] {
        
        return (1...rounds).compactMap{ round in
            var numbers = LottoInfo.randomNumbers(count: 7)
            guard let plus = numbers.popFirst() else {
                return nil
            }
            return WinNumbers(round: round, numbers: Array(numbers), plus: plus)
        }
    }
    
    @MainActor
    func newItem() -> WinNumbers? {
        let desc = FetchDescriptor<WinNumbers>()
        var round: Int = 0
        do {
            round = try self.mainContext.fetchCount(desc)
        } catch {
            fatalError(String(describing: error))
        }
        
        var numbers = LottoInfo.randomNumbers(count: 7)
        guard let plus = numbers.popFirst() else {
            return nil
        }
        
        return WinNumbers(round: round + 1, numbers: Array(numbers), plus: plus)
    }
    
    @MainActor
    func add() {
        
        guard let item = self.newItem() else {
            return
        }
        
        Task {
            let context = self.privateContext
            context.insert(item)
            try? context.save()
        }
    }
    
    func removeAll() {
        
        Task {
            
            let desc = FetchDescriptor<WinNumbers>()
            
            do {
                let context = self.privateContext
                
                let list = try context.fetch(desc)
                
                list.forEach { item in
                    context.delete(item)
                    
                    try? context.save()
                }
            } catch {
                fatalError(String(describing: error))
            }
        }
    }
    
    func createDummy(rounds: Int) {
        
        self.removeAll()
        
        Task {
            let context = self.privateContext
            
            let list = await self.getDummyNumbers(rounds: rounds)
            
            list.forEach { info in
                context.insert(info)
            }
            
            try? context.save()
        }
    }
}
