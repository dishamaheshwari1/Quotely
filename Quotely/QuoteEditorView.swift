//
//  QuoteEditorView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct QuoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // The quote we are editing (or nil if it's a new one)
    var quoteToEdit: Quote?
    
    // HELPER: checks if this is a past quote or the blank page
    var isHistoryItem: Bool {
        return quoteToEdit != nil
    }
    
    @State private var quoteText: String = ""
    @State private var noteText: String = ""
    @State private var colorIndex: Int = 0
    @State private var showSaveConfirmation: Bool = false
    @FocusState private var isFocused: Bool
    
    // JEWEL TONES
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
    
    var isLightBackground: Bool {
        return colorIndex == 0 || colorIndex == 3
    }
    
    var body: some View {
        ZStack {
            // LAYER 1: Background
            backgroundColors[colorIndex]
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: colorIndex)
                .onTapGesture { isFocused = false }
            
            // LAYER 2: Editor
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    TextField("type your quote here", text: $quoteText, axis: .vertical)
                        .fontDesign(.serif)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(isLightBackground ? .black : .white)
                        .focused($isFocused)
                        .padding(.top, 10)
                        // Disable typing on history items so keyboard doesn't pop up while scrolling
                        .disabled(isHistoryItem)
                    
                    TextField("note to self...", text: $noteText)
                        .fontDesign(.serif)
                        .font(.body)
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundColor(isLightBackground ? .black.opacity(0.8) : .white.opacity(0.8))
                        .focused($isFocused)
                        .disabled(isHistoryItem)
                }
                .padding(25)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                .padding(.horizontal, 30)
                .frame(minHeight: 150)
                
                Spacer()
                
                // LAYER 3: Buttons
                // Only show buttons on the NEW page. History items should be clean.
                if !isHistoryItem {
                    HStack(spacing: 40) {
                        Button(action: saveQuote) {
                            HStack {
                                Image(systemName: "arrow.up.doc.fill")
                                Text("Save")
                            }
                            .fontDesign(.serif)
                            .fontWeight(.medium)
                            .foregroundColor(isLightBackground ? .black : .white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 25)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                        }
                        
                        NavigationLink(destination: QuoteListView()) {
                            Image(systemName: "square.grid.2x2")
                                .font(.title2)
                                .foregroundColor(isLightBackground ? .black : .white)
                                .padding(15)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            
            // LAYER 4: Feedback
            if showSaveConfirmation {
                Text("Saved")
                    .fontDesign(.serif)
                    .font(.title3)
                    .foregroundColor(isLightBackground ? .black : .white)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .onAppear {
            if let existing = quoteToEdit {
                quoteText = existing.text
                noteText = existing.note
                colorIndex = existing.colorIndex
            }
        }
        // GESTURE LOGIC:
        // IF it is a history item: Pass 'nil' (No gesture). This lets the ScrollView handle the touch.
        // IF it is the new page: Pass 'DragGesture'. This handles color swipes and saving.
        .simultaneousGesture(
            isHistoryItem ? nil : DragGesture()
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    
                    // Horizontal Swipe (Change Color)
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount < -50 {
                            changeColor(direction: 1)
                        } else if horizontalAmount > 50 {
                            changeColor(direction: -1)
                        }
                    }
                    // Vertical Swipe UP (Save)
                    else if verticalAmount < -100 {
                        saveQuote()
                    }
                }
        )
    }
    
    func changeColor(direction: Int) {
        withAnimation {
            let count = backgroundColors.count
            if direction > 0 { colorIndex = (colorIndex + 1) % count }
            else { colorIndex = (colorIndex - 1 + count) % count }
        }
    }
    
    func saveQuote() {
        guard !quoteText.isEmpty else { return }
        
        // Always creating new in this context
        let newQuote = Quote(text: quoteText, note: noteText, colorIndex: colorIndex)
        modelContext.insert(newQuote)
        
        isFocused = false
        
        withAnimation { showSaveConfirmation = true }
        
        // Reset the blank page
        quoteText = ""
        noteText = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showSaveConfirmation = false }
        }
    }
}
