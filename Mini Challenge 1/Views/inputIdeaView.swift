//
//  DiscussionView.swift
//  Mini Challenge 1
//
//  Created by Michael Chrisandy on 02/04/24.
//

import SwiftUI
import Firebase

struct inputIdeaView: View {
    @State var room : Room = Room()
    @State var idea: String = ""
    @State private var isButtonDisabled = true
    
    @State var isMaster = false
    
    var body: some View {
        
        VStack{
            TextField("What's your idea?", text: $idea)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Submit idea") {
                let userID = UserDefaults.standard.string(forKey: "userID")!
                
                let ref = Database.database().reference()
                
                ref.child(room.id).child("players").child(userID).child("idea").setValue(idea)
                
                ref.child(room.id).child("info").child("ideaSubmitted").setValue(room.ideaSubmitted+1)
            }
            .padding()
            .background(isButtonDisabled ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(isButtonDisabled)
            .onChange(of: idea) {
                validateInputs()
            }
            
            Text("Idea submitted : \(room.ideaSubmitted)")
        }.onAppear{

            checkUserRole()
            
            let roomCode = GlobalMethod.getRoomCode()
            let postRef = Database.database().reference().child(roomCode!)
            
            _ = postRef.observe(DataEventType.value, with: { snapshot in
                guard snapshot.exists() else {
                    print("No data available")
                    return
                }
                
                if let value = snapshot.value as? [String: Any] {
                    mapValue(value: value)
                }
            })
            
            
        }
        
    }
    
    func validateInputs() {
        isButtonDisabled = idea.isEmpty
    }
    
    func mapValue(value: [String: Any]){
        print("keganti")
        room.id = GlobalMethod.getRoomCode()!
        
        let info = value["info"] as! [String: Any]
        
        room.topic = info["topic"] as! String
        room.status = info["status"] as! Int
        room.explainIdeaTurn = info["explainIdeaTurn"] as! String
        room.commentIdeaTurn = info["commentIdeaTurn"] as! String
        room.ideaSubmitted = info["ideaSubmitted"] as! Int
        
        let valuePlayer = value["players"] as! [String: [String:Any]]
        
        
        var newPlayers : [Player] = []
        for (id, data) in valuePlayer {
            newPlayers.append(Player(id: id, name: data["name"] as! String,  idea: data["idea"] as! String, role: data["role"] as! String))
        }
        
        room.players = newPlayers
        
        if(room.ideaSubmitted == room.players.count){
            let ref = Database.database().reference()
            
            ref.child(room.id).child("info").child("status").setValue(3)
        }
    }
    
    func checkUserRole() {
        GlobalMethod.isMaster { isValid in
            if isValid {
                isMaster = true
                print("User is a master")
            } else {
                isMaster = false
                print("User is not a master")
            }
        }
    }
    
    
}

//#Preview {
//    inputIdeaView()
//}
