//
//  MainFeedView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct MainFeedView: View {
    @Query(sort: \Quote.dateCreated, order: .forward) private var historyQuotes: [Quote]
    
    // Inputs from Navigation
    var startID: UUID?
    // If true, we hide the grid button in the editor (passed down)
    var hideGridButton: Bool = false
    
    var body: some View {
        // NO NavigationStack here (It is in the App file now)
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    
                    // 1. HISTORY FEED
                    ForEach(historyQuotes) { quote in
                        // Pass 'showGridButton: !hideGridButton'
                        QuoteEditorView(quote: quote, showGridButton: !hideGridButton)
                            .containerRelativeFrame(.vertical)
                            .id(quote.id)
                    }
                    
                    // 2. NEW ENTRY
                    QuoteEditorView(quote: nil, showGridButton: !hideGridButton)
                        .containerRelativeFrame(.vertical)
                        .id("NEW_ENTRY")
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .ignoresSafeArea()
            .background(.black)
            .defaultScrollAnchor(.bottom)
            .onAppear {
                if let target = startID {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        proxy.scrollTo(target, anchor: .center)
                    }
                } else {
                    proxy.scrollTo("NEW_ENTRY", anchor: .bottom)
                }
            }
        }
        // THIS KILLS THE SHADOW / TOP BAR
        .toolbar(.hidden, for: .navigationBar)
    }
}
