//
//  Book.swift
//  Books
//
//  Created by Torekhan Mukhtarov on 26.03.2024.
//

import Foundation
struct Book: Identifiable, Codable {
    var id: String
    var title: String
    var author: String
    var yearOfPublication: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case author
        case yearOfPublication
    }
}
