//
//  ContentView.swift
//  Books
//
//  Created by Torekhan Mukhtarov on 25.03.2024.
//

import SwiftUI
import Foundation

struct Home: View {
    @State private var books: [Book] = []
        
    @State var showAdd = false
    @State var showEdit = false
    @State var showDelete = false
    @State var deleteBook: Book?
        
    @State var updateBook: Book? // Changed from String to Book
    @State private var isEditMode: EditMode = .inactive
    @Environment(\.editMode) var editMode

    var alert: Alert {
            Alert(
                title: Text("Удалить"),
                message: Text("Вы уверены что хотите удалить книгу?"),
                primaryButton: .destructive(Text("Да"), action: deleteSelectedBook),
                secondaryButton: .cancel()
            )
        }

    var body: some View {
        NavigationView {
            List(books, id: \.id) { book in
                if self.editMode?.wrappedValue == .inactive {
                    let yearAsString = String(book.yearOfPublication) // Correct conversion of Int to String
                    Text("\(book.title) \(book.author) \(yearAsString)")
                        .padding()
                        .onLongPressGesture {
                            self.showDelete.toggle()
                            self.deleteBook = book
                        }
                } else {
                    HStack {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.yellow)
                            
                        Text("\(book.title) \(book.author) \(book.yearOfPublication)")
                            .padding()
                    }
                    .onTapGesture {
                        self.updateBook = book
                        self.showEdit.toggle()
                    }
                }
            }
            .alert(isPresented: $showDelete, content: {
                alert
            })
            .sheet(isPresented: $showEdit, onDismiss: fetchBooks) {
                UpdateBookView(book: $updateBook)
            }
            .sheet(isPresented: $showAdd, onDismiss: fetchBooks) {
                AddNewBooks()
            }
            .onAppear(perform: fetchBooks)
            .navigationTitle("Книги")
            .navigationBarItems(leading: Button(action: {
                if self.editMode?.wrappedValue == .active {
                        self.editMode?.wrappedValue = .inactive
                    } else {
                        self.editMode?.wrappedValue = .active
                    }
            }, label: {
                Text(self.editMode?.wrappedValue == .active ? "Готово" : "Изменить")
            }), trailing: Button(action: {
                self.showAdd.toggle()
            }, label: {
                Text("Добавить")
            }))
        }
    }
    
    func fetchBooks() {
        guard let url = URL(string: "https://work-418514.nw.r.appspot.com/books") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let books = try JSONDecoder().decode([Book].self, from: data)
                DispatchQueue.main.async {
                    self.books = books
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }

    func deleteSelectedBook() {
    guard let bookToDelete = deleteBook else {
        print("No book selected to delete.")
        return
    }

    let url = URL(string: "https://work-418514.nw.r.appspot.com/books/\(bookToDelete.id)")!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }

        DispatchQueue.main.async {
            self.books.removeAll { $0.id == bookToDelete.id }
            self.showDelete = false  // Hide the alert after deletion
        }
    }
    task.resume()
}
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
