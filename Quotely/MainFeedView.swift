//
//  MainFeedView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct MainFeedView: View {
    // Sort Oldest to Newest, so the "Newest" is right above the blank page
    @Query(sort: \Quote.dateCreated, order: .forward) private var historyQuotes: [Quote]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    
                    // PART 1: The History (Above the blank page)
                    ForEach(historyQuotes) { quote in
                        QuoteEditorView(quoteToEdit: quote)
                            .containerRelativeFrame(.vertical)
                            .id(quote.id) // Identify for scrolling if needed
                    }
                    
                    // PART 2: The New Entry (At the bottom)
                    QuoteEditorView(quoteToEdit: nil)
                        .containerRelativeFrame(.vertical)
                        .id("new_entry_page")
                }
            }
            .scrollTargetBehavior(.paging) // Snap to pages
            .ignoresSafeArea()
            .background(.black)
            // This magic line makes the app open at the bottom (The Blank Page)
            .defaultScrollAnchor(.bottom)
        }
    }
}

#Preview {
    MainFeedView()
        .modelContainer(for: Quote.self, inMemory: true)
}
