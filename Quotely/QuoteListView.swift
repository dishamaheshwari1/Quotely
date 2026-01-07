//
//  QuoteListView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct QuoteListView: View {
    // Connect to Database
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Quote.dateCreated, order: .reverse) private var quotes: [Quote]
    
    // Grid Layout: 2 columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Same colors for reference
    let backgroundColors: [Color] = [
        Color(red: 0.6, green: 0.05, blue: 0.1),
        Color(red: 0.05, green: 0.2, blue: 0.5),
        Color(red: 0.0, green: 0.4, blue: 0.25),
        Color(red: 0.35, green: 0.2, blue: 0.05),
        Color(red: 0.8, green: 0.3, blue: 0.0),
        Color(red: 0.9, green: 0.85, blue: 0.7)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if quotes.isEmpty {
                    ContentUnavailableView("No Quotes Yet", systemImage: "book.closed", description: Text("Swipe down on the main screen to save your first quote."))
                } else {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(quotes) { quote in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(quote.text)
                                    .fontDesign(.serif)
                                    .font(.headline)
                                    .lineLimit(4) // Only show first 4 lines
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(quote.colorIndex == 5 ? .black : .white)
                                
                                Spacer()
                                
                                Text(quote.dateCreated.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(quote.colorIndex == 5 ? .black.opacity(0.6) : .white.opacity(0.6))
                            }
                            .frame(height: 150) // Square-ish tile
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(backgroundColors[quote.colorIndex])
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                // Subtle border
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Journal")
            .background(Color.black.ignoresSafeArea()) // Dark background for the library
        }
    }
}

#Preview {
    QuoteListView()
        .modelContainer(for: Quote.self, inMemory: true)
}
