//
//  AddNewBooks.swift
//  Books
//
//  Created by Torekhan Mukhtarov on 26.03.2024.
//

import Foundation
import SwiftUI

struct AddNewBooks: View {
    @State private var title = ""
    @State private var author = ""
    @State private var yearOfPublication = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Название", text: $title)
                .padding()

            TextField("Автор", text: $author)
                .padding()

            TextField("Год публикации", text: $yearOfPublication)
                .keyboardType(.numberPad)
                .padding()

            Button("Добавить книгу", action: postBook)
                .padding()
        }
        .padding()
    }

    func postBook() {
        guard let year = Int(yearOfPublication) else {
            print("Invalid year of publication")
            return
        }

        let bookData = ["title": title, "author": author, "yearOfPublication": year] as [String: Any]

        let url = URL(string: "https://work-418514.nw.r.appspot.com/books")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bookData, options: [])
        } catch {
            print("Error creating JSON body: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            switch httpResponse.statusCode {
            case 200...299: // Successful response range
                print("Success: \(httpResponse.statusCode)")
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Response: \(json)")
                        }
                    } catch {
                        print("JSON error: \(error)")
                    }
                }
            default:
                print("HTTP Error: \(httpResponse.statusCode)")
            }
        }.resume()

        self.title = ""
        presentationMode.wrappedValue.dismiss()
    }
}
