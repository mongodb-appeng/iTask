//
//  ContentView.swift
//  iTask
//
//  Created by Andrew Morgan on 08/01/2020.
//  Copyright © 2020 ClusterDB. All rights reserved.
//

import SwiftUI

struct ListItem: View {
  @State private var task: Task
  
  var body: some View {
    Text("task")
  }
}

struct ContentView: View {
  @ObservedObject var tasks = Tasks()

  @State private var showingAddTask = false
  
  var body: some View {
    return NavigationView {
      List {
        ForEach(tasks.taskList) { item in
          HStack {
            Button(action: {
              item.complete.toggle()
              self.tasks.updateTask(item)
              
            }) {
              Image(systemName: item.complete ? "checkmark.circle.fill" : "circle")
              .padding()
            }
            VStack(alignment: .leading) {
              Text(item.name)
                .font(.headline)
                .padding(.bottom, 5)
              HStack {
                ForEach(item.tags, id: \.self) { tag in
                  Text(tag)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(item.complete ? Color.gray : Color.blue)
                    .clipShape(Capsule())
                }
              }
            }
            Spacer()
          }
          .foregroundColor(item.complete ? Color.gray : Color.primary)
        }
        .onDelete(perform: removeItems)
      }
      .navigationBarTitle("iTask")
      .navigationBarItems(leading: EditButton(), trailing: Button(action: {
        self.showingAddTask = true
      }) {
          Image(systemName: "plus")
        }
      )
    }
    .sheet(isPresented: $showingAddTask) {
      AddView(tasks: self.tasks)
    }
  }
  
  func removeItems(at offsets: IndexSet) {
    tasks.taskList.remove(atOffsets: offsets)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
