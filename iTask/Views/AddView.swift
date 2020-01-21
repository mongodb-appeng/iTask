//
//  AddView.swift
//  iTask
//
//  Created by Andrew Morgan on 09/01/2020.
//  Copyright © 2020 ClusterDB. All rights reserved.
//

import SwiftUI

struct AddView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var tasks: Tasks
  @State private var name = ""
  @State private var tag = ""
  @State private var tags: [String] = []
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Task name", text: $name)
        }
        Section {
          HStack {
            TextField("Tag", text: $tag)
            Button(action: addTag)
              {
                Image(systemName: "plus.circle.fill")
              }
          }
          ForEach(tags, id:\.self) { item in
            Button(action: { self.removeTag(item) })
              {
                Text(item)
              }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .clipShape(Capsule())
          }
        }
      }
    .navigationBarTitle("Add new task")
      .navigationBarItems(trailing: Button(action: saveTask){
        Text("Save")
      })
    }
  }
  
  func saveTask() {
    let item = Task(name: name, tags: tags)
    tasks.addTask(item)
    presentationMode.wrappedValue.dismiss()
  }
  
  func addTag() {
    if let _ = tags.firstIndex(of: tag) {
      // tag is already in the array
    } else {
      tags.append(tag)
    }
    tag = ""
  }
  
  func removeTag(_ tagName: String) {
    if let index = tags.firstIndex(of: tagName) {
      tags.remove(at: index)
    }
  }
}

struct AddView_Previews: PreviewProvider {
  static var previews: some View {
    AddView(tasks: Tasks())
  }
}
