//
//  UpdateBookView.swift
//  Books
//
//  Created by Torekhan Mukhtarov on 26.03.2024.
//

import SwiftUI
import Foundation

struct UpdateBookView: View {
    @Binding var book: Book?
    @Environment(\.presentationMode) var presentationMode

        var body: some View {
            VStack {
                TextField("Изменить название", text: Binding<String>(
                    get: { self.book?.title ?? "" },
                    set: { self.book?.title = $0 }
                ))
                .padding()

                TextField("Изменить автора", text: Binding<String>(
                    get: { self.book?.author ?? "" },
                    set: { self.book?.author = $0 }
                ))
                .padding()

                TextField("Изменить год публикации", text: Binding<String>(
                    get: { String(self.book?.yearOfPublication ?? 0) },
                    set: { self.book?.yearOfPublication = Int($0) ?? 0 }
                ))
                .keyboardType(.numberPad)
                .padding()

                Button("Изменить", action: updateBook)
                    .padding()
            }
            .padding()
        }

    func updateBook() {
        guard let book = book, let url = URL(string: "http://localhost:3000/books/\(book.id)") else {
                    print("Invalid URL or book data")
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "PATCH"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let bookData = [
                    "title": book.title,
                    "author": book.author,
                    "yearOfPublication": book.yearOfPublication
                ] as [String : Any]
        
        print("Data to send: \(bookData)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bookData, options: [])
            print("Request body: \(String(describing: String(data: request.httpBody!, encoding: .utf8)))")
        } catch {
            print("Error creating JSON body: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating book: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            print("HTTP Response Code: \(httpResponse.statusCode)")

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response from server: \(responseString)")
            }
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        task.resume()
    }
}
