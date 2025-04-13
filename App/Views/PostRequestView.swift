import SwiftUI

struct PostRequestView: View {
    @EnvironmentObject var dataStore: MockDataStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var meatType = ""
    @State private var quantity = ""
    @State private var unit = "pounds"
    @State private var budget = ""
    @State private var deliveryOption: DeliveryOption = .either
    @State private var preferredDate = Date().addingTimeInterval(60*60*24*7) // A week from now
    @State private var additionalInfo = ""
    @State private var showAlert = false
    
    let meatTypes = ["Beef", "Pork", "Chicken", "Lamb", "Turkey", "Bison", "Other"]
    let units = ["pounds", "kg", "whole animal"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Post a Meat Request")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Group {
                    Text("What type of meat are you looking for?")
                        .font(.headline)
                    
                    Picker("Meat Type", selection: $meatType) {
                        Text("Select a meat type").tag("")
                        ForEach(meatTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Group {
                    Text("How much do you want to purchase?")
                        .font(.headline)
                    
                    HStack {
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Picker("Unit", selection: $unit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                Group {
                    Text("What's your budget?")
                        .font(.headline)
                    
                    HStack {
                        Text("$")
                            .font(.headline)
                            .padding(.leading)
                        
                        TextField("Budget", text: $budget)
                            .keyboardType(.decimalPad)
                            .padding([.top, .bottom, .trailing])
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Group {
                    Text("Delivery preference?")
                        .font(.headline)
                    
                    Picker("Delivery Option", selection: $deliveryOption) {
                        ForEach(DeliveryOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Group {
                    Text("When do you need it by?")
                        .font(.headline)
                    
                    DatePicker("Preferred Date", selection: $preferredDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                Group {
                    Text("Additional information")
                        .font(.headline)
                    
                    TextEditor(text: $additionalInfo)
                        .frame(minHeight: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.bottom)
                }
                
                Button(action: submitRequest) {
                    Text("Post Request")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.green : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid)
                .padding(.vertical)
                .alert("Request Posted", isPresented: $showAlert) {
                    Button("OK") {
                        dismiss()
                    }
                } message: {
                    Text("Your meat request has been posted to the board. Farmers will be able to see it and contact you.")
                }
            }
            .padding()
        }
        .navigationTitle("Post Request")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isFormValid: Bool {
        !meatType.isEmpty && 
        !quantity.isEmpty && 
        Double(quantity) != nil && 
        !budget.isEmpty && 
        Double(budget) != nil
    }
    
    private func submitRequest() {
        guard let currentUser = dataStore.currentUser, let quantityValue = Double(quantity), let budgetValue = Double(budget) else { return }
        
        let newRequest = Request(
            consumerId: currentUser.id,
            consumerName: currentUser.name,
            meatType: meatType,
            quantity: quantityValue,
            unit: unit,
            budget: budgetValue,
            deliveryOption: deliveryOption,
            preferredTime: preferredDate,
            location: currentUser.location,
            additionalInfo: additionalInfo
        )
        
        dataStore.addRequest(newRequest)
        showAlert = true
    }
}

#Preview {
    NavigationStack {
        PostRequestView()
            .environmentObject(MockDataStore())
    }
} 