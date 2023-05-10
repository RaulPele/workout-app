//
//  ListView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 07.05.2023.
//

import SwiftUI

struct ListView<Item: Identifiable, RowContent: View>: View {
    
    let items: [Item]
    
    private let spacing: CGFloat
    private let alignment: HorizontalAlignment
    private let backgroundColor: Color
    private let showDividers: Bool
    
    @ViewBuilder private let rowContent: (Item) -> RowContent
    
    init(items: [Item],
         spacing: CGFloat = 10,
         alignment: HorizontalAlignment = .leading,
         showDividers: Bool = true,
         backgroundColor: Color = Color.background,
         @ViewBuilder rowContent: @escaping (Item) -> RowContent) {
        self.items = items
        self.spacing = spacing
        self.alignment = alignment
        self.backgroundColor = backgroundColor
        self.showDividers = showDividers
        self.rowContent = rowContent
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(items) { item in
                rowContent(item)
                if shouldAddDivider(for: item) {
                    dividerView
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .init(horizontal: alignment, vertical: .center)
        )
        .padding()
        .background(backgroundColor)
        .cornerRadius(15)
    }
    
    private var dividerView: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.gray)
            .frame(height: 1)
    }
    
    private func shouldAddDivider(for item: Item) -> Bool {
        return showDividers && item.id != items.last?.id
    }
}

#if DEBUG
struct ListView_Previews: PreviewProvider {
    
    struct Item: Identifiable {
        let id = UUID()
        var text = "Test"
    }
    
    static let items: [Item] = [.init(), .init(), .init()]
    
    static var previews: some View {
        ListView(items: items, backgroundColor: .blue) { item in
            Text(item.text)
        }
        
    }
}
#endif
