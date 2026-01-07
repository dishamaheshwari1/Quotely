//
//  MainFeedView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct MainFeedView: View {
    // Fetch all quotes, sorted by NEWEST first
    @Query(sort: \Quote.dateCreated, order: .reverse) private var recentQuotes: [Quote]
    
    var body: some View {
        NavigationStack {
            // Vertical Paging ScrollView
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    
                    // PAGE 1: The "New Quote" Editor
                    // It takes up the full screen height
                    QuoteEditorView(quoteToEdit: nil)
                        .containerRelativeFrame(.vertical) // Forces it to be 1 page tall
                        .id("new_entry_page")
                    
                    // PAGE 2+: The History
                    // We loop through saved quotes and show them as full pages
                    ForEach(recentQuotes) { quote in
                        QuoteEditorView(quoteToEdit: quote)
                            .containerRelativeFrame(.vertical)
                            // We disable the "Save" button visually for history items if you prefer,
                            // or keep it so they can edit on the fly while scrolling.
                            // For this MVP, we are reusing the full editor so you can edit past quotes immediately!
                    }
                }
            }
            .scrollTargetBehavior(.paging) // Snap to each page
            .ignoresSafeArea()
            .background(.black) // Background for the "gaps" between pages if any
        }
    }
}

#Preview {
    MainFeedView()
        .modelContainer(for: Quote.self, inMemory: true)
}
