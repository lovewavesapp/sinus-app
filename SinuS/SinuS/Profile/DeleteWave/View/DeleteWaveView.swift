//
//  DeleteWaveView.swift
//  SinuS
//
//  Created by Loe Hendriks on 26/03/2023.
//

import SwiftUI

struct DeleteWaveView: View {
    //var waves: [SinusUserData]
    
    @State private var selection = ""
    @State private var message: String = ""
    @State private var showingAlert = false
    @State private var isPresentingConfirm: Bool = false
    
    var deleteWaveModel = DeleteWaveModel(retrievable: ExternalRestRetriever())
    
    var options: [String] {
        return deleteWaveModel.waves.map { "\($0.date_name)" }
    }
    
    var selectedWave: SinusUserData {
        if (self.selection == "") {
            return self.deleteWaveModel.waves.first!
        }
            
        var wave = self.deleteWaveModel.waves.filter{ $0.date_name == self.selection }.first
        return wave!
    }
    
    init(waves: [SinusUserData]) {
        self.deleteWaveModel.setWaves(waves: waves)
       // self.waves = waves
    }
    
    var body: some View {
        if (options.count != 0) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "trash")
                        .padding(.leading, 15)
                        .padding(.top, 5)
                    Text("Delete wave")
                        .font(.headline)
                        .padding(.top, 5)
                }.foregroundColor(Style.AppColor)
                
                Spacer()
                
                VStack {
                    HStack {
                        Text("Wave").foregroundColor(Style.TextOnColoredBackground)
                        
                        Spacer()
                        
                        Picker("Choose...", selection: self.$selection) {
                            ForEach(options, id: \.self) {
                                Text($0)
                            }
                        }
                        .colorMultiply(Style.AppColor)
                        .accentColor(Style.TextOnColoredBackground)
                        .cornerRadius(5)
                        .shadow(radius: 10)
                    }.padding(.horizontal).padding(.top)
                    
                    Button("Delete") {
                        let resign = #selector(UIResponder.resignFirstResponder)
                        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                        isPresentingConfirm = true
                    }
                    .padding()
                    .confirmationDialog("Are you sure?",
                    isPresented: $isPresentingConfirm) {
                        Button("Delete Wave", role: .destructive) {
                            Task {
                                do {
                                    self.message = await self.deleteWaveModel.deleteWave(wave_id: self.selectedWave.id)
                                    showingAlert = true
                                }
                                catch{
                                    print(error)
                                }
                            }
                        }
                    } message: {
                      Text("You cannot undo this action")
                    }
                    .alert(self.message, isPresented: $showingAlert) {
                        Button("OK", role: .cancel) {}
                    }
                }
                .background(Style.AppBackground)
                .foregroundColor(Style.TextOnColoredBackground)
                .cornerRadius(5)
                .padding()
                .foregroundColor(.white)
                
                Spacer()
            }
        }
    }
}

struct DeleteWaveView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteWaveView(waves: [])
    }
}
