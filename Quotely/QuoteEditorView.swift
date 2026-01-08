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
    
    // --- INPUTS ---
    let quote: Quote?
    
    var isNewEntryMode: Bool { quote == nil }
    
    // --- LOCAL STATE (For New Entries) ---
    @State private var tempText: String = ""
    @State private var tempNote: String = ""
    @State private var tempColorIndex: Int = 0
    
    // --- UI STATE ---
    @FocusState private var isFocused: Bool
    @State private var showSaveFeedback: Bool = false
    
    // --- JEWEL TONES ---
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
    
    var activeColorIndex: Int {
        isNewEntryMode ? tempColorIndex : (quote?.colorIndex ?? 0)
    }
    
    var isLightBackground: Bool {
        return activeColorIndex == 0 || activeColorIndex == 3
    }
    
    var textColor: Color { isLightBackground ? .black : .white }
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND
            backgroundColors[activeColorIndex]
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: activeColorIndex)
                .onTapGesture { isFocused = false }
            
            // 2. CENTERED TEXT
            VStack(spacing: 25) {
                Spacer()
                
                // MAIN QUOTE INPUT
                TextField("type your quote here", text: Binding(
                    get: { isNewEntryMode ? tempText : quote!.text },
                    set: { val in if isNewEntryMode { tempText = val } else { quote!.text = val } }
                ), axis: .vertical)
                .fontDesign(.serif)
                .font(.system(size: 34, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .tint(textColor)
                .focused($isFocused)
                .padding(.horizontal, 24)
                
                // NOTE TO SELF INPUT
                TextField("note to self...", text: Binding(
                    get: { isNewEntryMode ? tempNote : quote!.note },
                    set: { val in if isNewEntryMode { tempNote = val } else { quote!.note = val } }
                ))
                .fontDesign(.serif)
                .font(.body)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(textColor.opacity(0.6))
                .tint(textColor)
                .focused($isFocused)
                
                Spacer()
            }
            .padding(.bottom, 90) // Clear the toolbar
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 3. FEEDBACK OVERLAY
            if showSaveFeedback {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(textColor.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
            }
        }
        // 4. LIQUID TOOLBAR (FIXED OVERLAY)
        .overlay(alignment: .bottom) {
            HStack {
                // LEFT GROUP: [Edit | Save | Delete | Grid]
                HStack(spacing: 22) {
                    
                    // 1. EDIT / KEYBOARD TOGGLE
                    Button { isFocused.toggle() } label: {
                        Image(systemName: isFocused ? "checkmark" : "square.and.pencil")
                    }
                    
                    // 2. SAVE BUTTON (Standard Icon)
                    Button(action: saveAction) {
                        Image(systemName: showSaveFeedback ? "checkmark" : "square.and.arrow.down")
                    }
                    .disabled(isNewEntryMode && tempText.isEmpty)
                    .opacity((isNewEntryMode && tempText.isEmpty) ? 0.4 : 1.0)
                    
                    // 3. DELETE BUTTON (Trash Can)
                    Button(action: deleteAction) {
                        Image(systemName: "trash")
                    }
                    
                    // 4. GRID / LIBRARY
                    NavigationLink(destination: QuoteListView()) {
                        Image(systemName: "square.grid.2x2")
                    }
                }
                .font(.system(size: 20, weight: .light))
                .foregroundColor(textColor)
                .padding(.vertical, 14)
                .padding(.horizontal, 24)
                // --- TRUE LIQUID GLASS STYLE ---
                .background(.ultraThinMaterial) // Blurs what is behind
                .background(Color.white.opacity(0.1)) // Adds a glass tint
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5) // Lift it off the bg
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.3), lineWidth: 1) // Crisp edge highlight
                )
                
                Spacer()
                
                // RIGHT GROUP: [Share]
                Button(action: { /* Share Placeholder */ }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(textColor)
                        .padding(14)
                        .background(.ultraThinMaterial)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        // GESTURES
        .simultaneousGesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    
                    if abs(horizontal) > abs(vertical) {
                        // Horizontal Swipe: Color Change
                        let direction = horizontal < 0 ? 1 : -1
                        changeColor(direction: direction)
                    } else if vertical < -100 && isNewEntryMode {
                        // Vertical Swipe Up: Save (Only New Entry)
                        saveAction()
                    }
                }
        )
    }
    
    // --- LOGIC ---
    
    func deleteAction() {
        withAnimation {
            if isNewEntryMode {
                tempText = ""
                tempNote = ""
                isFocused = false
            } else {
                if let q = quote {
                    modelContext.delete(q)
                }
            }
        }
    }
    
    func changeColor(direction: Int) {
        withAnimation {
            let count = backgroundColors.count
            let current = activeColorIndex
            
            var newIndex = current + direction
            if newIndex < 0 { newIndex = count - 1 }
            else if newIndex >= count { newIndex = 0 }
            
            if isNewEntryMode {
                tempColorIndex = newIndex
            } else {
                quote!.colorIndex = newIndex
            }
        }
    }
    
    func saveAction() {
        if isNewEntryMode {
            guard !tempText.isEmpty else { return }
            let newQuote = Quote(text: tempText, note: tempNote, colorIndex: tempColorIndex)
            modelContext.insert(newQuote)
            
            withAnimation { showSaveFeedback = true }
            tempText = ""
            tempNote = ""
            isFocused = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { showSaveFeedback = false }
            }
        } else {
            withAnimation { showSaveFeedback = true }
            isFocused = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showSaveFeedback = false }
            }
        }
    }
}
