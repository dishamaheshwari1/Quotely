//
//  QuoteListView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct QuoteListView: View {
    @Query(sort: \Quote.dateCreated, order: .reverse) private var quotes: [Quote]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    // Grid Preview Colors
    let backgroundColors: [Color] = [
        Color(red: 0.925, green: 0.784, blue: 0.604), // Sepia
        Color(red: 0.6, green: 0.05, blue: 0.1),      // Ruby
        Color(red: 0.8, green: 0.3, blue: 0.0),       // Orange
        Color(red: 0.95, green: 0.75, blue: 0.1),     // Yellow
        Color(red: 0.0, green: 0.4, blue: 0.25),      // Emerald
        Color(red: 0.05, green: 0.2, blue: 0.5),      // Sapphire
        Color(red: 0.35, green: 0.1, blue: 0.55),     // Purple
        Color(red: 0.35, green: 0.2, blue: 0.05),     // Brown
        Color(red: 0.25, green: 0.3, blue: 0.35),     // Slate
        Color.black
    ]
    
    var body: some View {
        ScrollView {
            if quotes.isEmpty {
                ContentUnavailableView("No Quotes Yet", systemImage: "text.book.closed")
                    .padding(.top, 50)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(quotes) { quote in
                        // MAGIC LINK: Opens the Main Feed, anchored to THIS quote
                        // ... inside the ForEach ...
                        NavigationLink(destination: MainFeedView(startID: quote.id, hideGridButton: true)) {
                            QuoteGridItem(quote: quote, color: backgroundColors[quote.colorIndex])
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("My Quotes")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.ignoresSafeArea())
    }
}

// Subview for the Grid Tile Look
struct QuoteGridItem: View {
    let quote: Quote
    let color: Color
    
    var isLight: Bool { quote.colorIndex == 0 || quote.colorIndex == 3 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.text)
                .fontDesign(.serif)
                .font(.headline)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .foregroundColor(isLight ? .black : .white)
            
            Spacer()
            
            Text(quote.dateCreated.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(isLight ? .black.opacity(0.6) : .white.opacity(0.6))
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }
}
