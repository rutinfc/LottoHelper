//
//  ItemListView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import SwiftUI
import SwiftData

struct ItemListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [CheckNumbers]
    
    var body: some View {
        
        List {
            ForEach(items) { item in
                NavigationLink {
                    Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(item.round)")
                                .frame(width: 40, alignment: .leading)
                                .font(.subheadline)
                                .padding(.trailing, 8)
                            NumbersCircleView(numbers: item.numbers)
                            Spacer()
                        }
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                }
            }
            .onDelete(perform: deleteItems)
        }
//        .toolbar {
//#if os(iOS)
//            ToolbarItem(placement: .navigationBarTrailing) {
//                EditButton()
//            }
//#endif
////            ToolbarItem {
////                Button(action: addItem) {
////                    Label("Add Item", systemImage: "plus")
////                }
////            }
//        }
        
    }
    
    private func addItem() {
        withAnimation {
//            let newItem = CheckNumbers(timestamp: Date())
//            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
        }
    }
}

#Preview {
    ItemListView()
}
