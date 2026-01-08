//
//  MainFeedView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct MainFeedView: View {
    // Sort Oldest to Newest. This puts history above the New Page.
    @Query(sort: \Quote.dateCreated, order: .forward) private var historyQuotes: [Quote]
    
    // Optional: If coming from library, which quote to jump to?
    var startID: UUID?
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        
                        // 1. HISTORY FEED (Scroll UP to see these)
                        ForEach(historyQuotes) { quote in
                            QuoteEditorView(quote: quote)
                                .containerRelativeFrame(.vertical)
                                .id(quote.id)
                        }
                        
                        // 2. NEW ENTRY (Bottom Page - Default Launch)
                        QuoteEditorView(quote: nil)
                            .containerRelativeFrame(.vertical)
                            .id("NEW_ENTRY")
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .ignoresSafeArea()
                .background(.black)
                // Ensures we start at the New Entry at the bottom
                .defaultScrollAnchor(.bottom)
                .onAppear {
                    // Logic to handle Library navigation
                    if let target = startID {
                        // If coming from Library, jump to that quote
                        // Small delay to ensure layout is computed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            proxy.scrollTo(target, anchor: .center)
                        }
                    } else {
                        // Redundant check to ensure we are at bottom on launch
                        proxy.scrollTo("NEW_ENTRY", anchor: .bottom)
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
