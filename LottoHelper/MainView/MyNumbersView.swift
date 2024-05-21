//
//  ItemListView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import SwiftUI
import SwiftData

struct MyNumbersView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @SectionedQuery(\.round, sort: \.timestamp) private var result: SectionedResults<Int, CheckNumbers>
    
    init(order: SortOrder = .forward) {
        _result = SectionedQuery(\.round, sort:\.timestamp, order: order)
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Text("My Numbers").font(.title)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            List(result) { section in
                
                Section {
                    ForEach(section) { item in
                        NavigationLink {
                            NumbersDetailView(item: item)
                        } label: {
                            RoundNumbersItemView(numbers: item.numbers, timestamp: item.timestamp)
                                .padding(.vertical, 8)
                        }
                        .contextMenu {
                            Button {
                                self.delete(item: item)
                            } label: {
                                Image(systemName: "trash")
                                Text("Remove")
                            }
                            .frame(width: 40, height: 40)
                        }
                        .swipeActions {
                            Button {
                                self.delete(item: item)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                        .onChange(of: item.numbers) { oldValue, newValue in
                            guard newValue.count == 0 else {
                                return
                            }
                            
                            self.delete(item: item)
                        }
                    }
                } header: {
                    Text(String(section.id)).font(.largeTitle)
                }
            }
            
        }
    }
    
    private func addItem() {
        withAnimation {
//            let newItem = CheckNumbers(timestamp: Date())
//            modelContext.insert(newItem)
        }
    }

    private func delete(item: CheckNumbers) {
        withAnimation {
            modelContext.delete(item)
        }
    }
    
}

extension Array where Iterator.Element: Hashable {
    
    func uniqued() -> [Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
    
}

struct SectionedResults<SectionIdentifier, Result>: RandomAccessCollection where SectionIdentifier: Hashable, Result: PersistentModel {
    
    typealias Element  = Self.Section
    typealias Index    = Int
    typealias Iterator = IndexingIterator<Self>
    
    var elements: [Element]
    var startIndex: Index = 0
    var endIndex: Index { elements.count }
    
    subscript(position: Index) -> Element {
        elements[position]
    }
    
    init(sectionIdentifier: KeyPath<Result, SectionIdentifier>, results: [Result]) {
        let groupedResults = Dictionary(grouping: results) { result in
            result[keyPath: sectionIdentifier]
        }
        
        let identifiers = results.map { result in
            result[keyPath: sectionIdentifier]
        }.uniqued()
        
        self.elements = identifiers.compactMap { identifier in
            guard let elements = groupedResults[identifier] else { return nil }
            return Section(id: identifier, elements: elements)
        }
    }
    
    struct Section: RandomAccessCollection, Identifiable {
        
        typealias Element  = Result
        typealias ID       = SectionIdentifier
        typealias Index    = Int
        typealias Iterator = IndexingIterator<Self>
        
        var id: ID
        var elements: [Element]
        var startIndex: Index = 0
        var endIndex: Index { elements.count }
        
        subscript(position: Index) -> Element {
            elements[position]
        }
    }

}

@propertyWrapper
struct SectionedQuery<SectionIdentifier, Result>: DynamicProperty where SectionIdentifier: Hashable, Result: PersistentModel {
    
    private let sectionIdentifier: KeyPath<Result, SectionIdentifier>
    @Query private var results: [Result]
    
    var wrappedValue: SectionedResults<SectionIdentifier, Result> {
        SectionedResults(sectionIdentifier: sectionIdentifier, results: results)
    }

    init<Value>(_ sectionIdentifier: KeyPath<Result, SectionIdentifier>,
                filter: Predicate<Result>? = nil,
                sort keyPath: KeyPath<Result, Value>,
                order: SortOrder = .forward,
                animation: Animation = .default) where Value: Comparable {
        self.sectionIdentifier = sectionIdentifier
        _results = Query(filter: filter,
                         sort: keyPath,
                         order: order,
                         animation: animation)
    }
}

#Preview {
    MyNumbersView()
}
