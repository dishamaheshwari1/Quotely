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
    
    var startID: UUID?
    var isFromLibrary: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    
                    // 1. HISTORY FEED
                    ForEach(historyQuotes) { quote in
                        QuoteEditorView(quote: quote, isFromLibrary: isFromLibrary)
                            // THE FIX: Absolute height instead of relative safe-area height
                            .frame(height: UIScreen.main.bounds.height)
                            .id(quote.id)
                    }
                    
                    // 2. NEW ENTRY
                    QuoteEditorView(quote: nil, isFromLibrary: isFromLibrary)
                        // THE FIX: Absolute height
                        .frame(height: UIScreen.main.bounds.height)
                        .id("NEW_ENTRY")
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            // Force the scrollview itself to ignore all boundaries
            .ignoresSafeArea(.all)
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
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.all)
    }
}
