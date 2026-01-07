//
//  MainFeedView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct MainFeedView: View {
    // Sort Oldest -> Newest (History grows downwards, ending at the Blank Page)
    @Query(sort: \Quote.dateCreated, order: .forward) private var historyQuotes: [Quote]
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    // CHANGED: LazyVStack -> VStack
                    // This ensures the scrollview "knows" the history exists above you immediately.
                    VStack(spacing: 0) {
                        
                        // PART 1: The History (Above)
                        ForEach(historyQuotes) { quote in
                            QuoteEditorView(quoteToEdit: quote)
                                .containerRelativeFrame(.vertical)
                                .id(quote.id) // Unique ID for every quote
                        }
                        
                        // PART 2: The New Entry (Bottom)
                        QuoteEditorView(quoteToEdit: nil)
                            .containerRelativeFrame(.vertical)
                            .id("new_entry_page") // We will auto-scroll to this
                    }
                }
                .scrollTargetBehavior(.paging) // Snap to pages
                .ignoresSafeArea()
                .background(.black)
                .onAppear {
                    // Force jump to the bottom (The Blank Page) immediately
                    // The .immediate update ensures you don't see it scrolling
                    proxy.scrollTo("new_entry_page", anchor: .bottom)
                }
                // Also scroll to bottom when a new quote is added
                .onChange(of: historyQuotes.count) {
                    withAnimation {
                        proxy.scrollTo("new_entry_page", anchor: .bottom)
                    }
                }
            }
        }
    }
}

#Preview {
    MainFeedView()
        .modelContainer(for: Quote.self, inMemory: true)
}
