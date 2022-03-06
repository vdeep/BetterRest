//
//  ContentView.swift
//  BetterRest
//
//  Created by Vishal on 05/03/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    var calculatedBedtime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60 * 60

            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )

            let sleepTime = wakeUp - prediction.actualSleep

            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Unknown"
        }
    }

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    } header: {
                        Text("When do you want to wake up?")
                            .font(.headline)
                    }

                    Section {
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    } header: {
                        Text("Desired amount of sleep")
                            .font(.headline)
                    }

                    Section {
                        Picker("Number of cups", selection: $coffeeAmount) {
                            ForEach(1...20, id: \.self) {
                                Text("\($0) cup\($0 > 1 ? "s" : "")")
                            }
                        }
                    } header: {
                        Text("Daily coffee intake")
                            .font(.headline)
                    }
                }

                Text("Your ideal bedtime is...")

                Text(calculatedBedtime)
                    .font(.largeTitle)
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
