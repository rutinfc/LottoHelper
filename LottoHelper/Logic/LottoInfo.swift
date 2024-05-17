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
    
    static let list = Array(1...46)
    
    static func randomNumbers(count: Int = 7, exception: [Int]? = nil) -> Set<Int> {
        
        var numbers = Set<Int>()
        
        if let list = exception {
            numbers.formUnion(list)
        }
        
        while numbers.count < count {
            let number = Int.random(in: (1...46))
            if numbers.contains(number) {
                break
            }
            numbers.insert(number)
        }
        
        return numbers
    }
    
    actor WinsNumberSync {
        
        func createDummy(rounds: Int) async -> [WinNumbers] {
            
            return (1...rounds).compactMap{ round in
                var numbers = LottoInfo.randomNumbers()
                guard let plus = numbers.popFirst() else {
                    return nil
                }
                return WinNumbers(round: round, numbers: Array(numbers), plus: plus)
            }
        }
    }
    
    static let winsNumber = WinsNumberSync()
    
    @MainActor
    final class Container {
        
        static let shared = Container()
        
        var modelContainer: ModelContainer = {
            let schema = Schema([
                WinNumbers.self,
                CheckNumbers.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
        
        @MainActor var mainContext: ModelContext {
            self.modelContainer.mainContext
        }
        
        fileprivate lazy var privateContext: ModelContext = {
            ModelContext(modelContainer)
        }()
    }
    
    final class CheckIntent {
        
        @MainActor func save(numbers: [Int]) {
            let desc = FetchDescriptor<WinNumbers>()
            var round: Int = 0
            do {
                round = try Container.shared.mainContext.fetchCount(desc)
            } catch {
                fatalError(String(describing: error))
            }
            
            let item = CheckNumbers(round: round + 1, numbers: numbers, timestamp: Date())
            
            Task {
                let context = Container.shared.privateContext
                
                context.insert(item)
            }
        }
    }
    
    final class WinIntent {
        
        private var cancelBag = Set<AnyCancellable>()
        
        init() {
            
            let publisher = NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)
                .compactMap({$0.userInfo})
            
            let update = publisher.compactMap({ $0[NSUpdatedObjectsKey] as? Set<NSManagedObject> })
            let delete = publisher.compactMap({ $0[NSDeletedObjectsKey] as? Set<NSManagedObject> })
            let insert = publisher.compactMap({ $0[NSInsertedObjectsKey] as? Set<NSManagedObject> })
            let refreshed = publisher.compactMap({ $0[NSRefreshedObjectsKey] as? Set<NSManagedObject> })
            
            Publishers.Merge4(update, delete, insert, refreshed).sink { result in
                if result.count > 0 {
//                    print("<---\(result) | \(Container.shared.mainContext)")
                    
                }
            }.store(in: &self.cancelBag)
        }
        
        @MainActor func newItem() -> WinNumbers? {
            let desc = FetchDescriptor<WinNumbers>()
            var round: Int = 0
            do {
                round = try Container.shared.mainContext.fetchCount(desc)
            } catch {
                fatalError(String(describing: error))
            }
            
            var numbers = LottoInfo.randomNumbers()
            guard let plus = numbers.popFirst() else {
                return nil
            }
            
            return WinNumbers(round: round + 1, numbers: Array(numbers), plus: plus)
        }
        
        @MainActor func add() {
            
            guard let item = self.newItem() else {
                return
            }
            
            Task {
                let context = Container.shared.privateContext
                context.insert(item)
                try? context.save()
            }
        }
        
        @MainActor func removeAll() {
            
            Task {
                
                let desc = FetchDescriptor<WinNumbers>()
                
                do {
                    let context = Container.shared.privateContext
                    
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
        
        @MainActor func createDummy(rounds: Int) {
            
            self.removeAll()
            
            Task {
                let context = Container.shared.privateContext
                
                let list = await LottoInfo.winsNumber.createDummy(rounds: rounds)
                
                list.forEach { info in
                    context.insert(info)
                }
                
                try? context.save()
            }
        }
    }
}

