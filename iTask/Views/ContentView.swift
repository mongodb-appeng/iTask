//
//  ContentView.swift
//  iTask
//
//  Created by Andrew Morgan on 08/01/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//  See https://github.com/mongodb-appeng/iTask/LICENSE for license details
//

import SwiftUI

// MARK: TIMER
/*
 The GraphQL API authorization token is only valid for a specific period and
 it's necessary to periodically re-auhtorize
 */
class TimerHolder : ObservableObject {
  var timer : Timer!
  func start(tasks: Tasks) {
    self.timer?.invalidate()
    self.timer = Timer.scheduledTimer(withTimeInterval: Constants.STITCH_GRAPHQL_TOKEN_TIMEOUT*60*0.75, repeats: true) { _ in
      print("Timer expired")
      graphQL.connect(tasks: tasks)
    }
  }
  
  func stop() {
    print("Stopping timer")
    self.timer?.invalidate()
  }
}

// MARK: VIEW

struct ContentView: View {
  @ObservedObject var tasks = Tasks()
  @ObservedObject var connectTimer = TimerHolder()
  @State private var showingAddTask = false
  
  var body: some View {
    return NavigationView {
      List {
        ForEach(tasks.taskList, id: \._id) { item in
          HStack {
            Button(action: {
              item.active.toggle()
              self.tasks.updateTask(item)
              
            }) {
              Image(systemName: item.active ? "circle" : "checkmark.circle.fill")
                .padding()
            }
            VStack(alignment: .leading) {
              Text(item.name)
                .font(.headline)
                .padding(.bottom, 5)
              Text(Date.getPrintStringFromISOString(item.dueBy))
                .font(.footnote)
                .foregroundColor(item.active ? Color.green : Color.gray)
                .padding(.bottom, 5)
              HStack {
                ForEach(item.tags, id: \.self) { tag in
                  Text(tag)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(item.active ? Color.blue : Color.gray)
                    .clipShape(Capsule())
                }
              }
            }
            Spacer()
          }
          .foregroundColor(item.active ? Color.primary : Color.gray)
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
        .onAppear() {
          self.connectTimer.start(tasks: self.tasks)
      }
      .onDisappear() {
        self.connectTimer.stop()
      }
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
        print("Moving to the background")
        self.connectTimer.stop()
      }
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
        print("Moving back to the foreground")
        self.connectTimer.start(tasks: self.tasks)
      }
    }
    .sheet(isPresented: $showingAddTask) {
      AddView(tasks: self.tasks)
    }
  }
  
  func removeItems(at offsets: IndexSet) {
    offsets.forEach() { index in
      self.tasks.deleteTask(self.tasks.taskList[index])
    }
  }
  
  func connect() {
    graphQL.connect(tasks: tasks)
  }
}

// MARK: PREVIEW

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
