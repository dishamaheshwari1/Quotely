//
//  Quote.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import Foundation
import SwiftData
import SwiftUI

// @Model tells Swift that this class can be saved to the database.
// This works on iPhone, iPad, Mac, and Watch automatically.
@Model
final class Quote {
    // A unique ID is helpful for finding specific quotes later
    var id: UUID
    
    // The main content of the quote
    var text: String
    
    // The "Note to self" section
    var note: String
    
    // When the user created it (useful for sorting)
    var dateCreated: Date
    
    // We save the color as an Integer index (0 = Red, 1 = Blue, etc.)
    // This is much lighter on storage than saving the full color data.
    var colorIndex: Int
    
    init(text: String, note: String, colorIndex: Int) {
        self.id = UUID()
        self.text = text
        self.note = note
        self.dateCreated = Date()
        self.colorIndex = colorIndex
    }
}
