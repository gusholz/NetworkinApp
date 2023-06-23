//
//  ContentView.swift
//  Requisicoes
//
//  Created by Gustavo Holzmann on 22/06/23.
//

import SwiftUI

struct GitHubUser: Codable{
    var login: String
    var avatarUrl: String
    var bio: String?
}

struct ContentView: View {
    @State private var user: GitHubUser = GitHubUser(login: "", avatarUrl: "", bio: "")
    @State private var searchTerm: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Github Users")
                .font(.largeTitle)
            HStack{
                TextField("adicione seu username", text: $searchTerm)
                    .textFieldStyle(.roundedBorder)
                    .padding(8)
                    .overlay(
                            RoundedRectangle(cornerRadius: 10) // Define o raio das bordas
                                .stroke(Color.gray, lineWidth: 2) // Define a cor e a largura das bordas
                    )
                Button("Enviar") {
                    Task {
                        do {
                            let fetchedUser = try await getUser(searchTerm)
                            user.login = fetchedUser.login
                            user.avatarUrl = fetchedUser.avatarUrl
                            user.bio = fetchedUser.bio
                            print(user)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .padding()
                .overlay(
                        RoundedRectangle(cornerRadius: 10) // Define o raio das bordas
                            .stroke(Color.gray, lineWidth: 2) // Define a cor e a largura das bordas
                )
                .padding()
            }
            HStack{
                Button("Resetar") {
                    searchTerm = ""
                    user.login = ""
                    user.avatarUrl = ""
                    user.bio = ""
                }
                
                Spacer()
            }.padding(.top)
            
            SubView(githubUser: $user)
                .padding(.top)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    func getUser(_ user: String) async throws -> GitHubUser {
        let myURL = "https://api.github.com/users/\(user)"
        
        guard let url = URL(string: myURL) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            print("Error: \(error.localizedDescription)")
            throw NetworkError.invalidConversion
        }
    }
}

struct SubView: View {
    @Binding var githubUser: GitHubUser
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage (url: URL(string: githubUser.avatarUrl )) {image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 150,height: 150)
            } placeholder: {
                Circle()
                    .foregroundColor (.secondary)
                    .frame(width: 150,height: 150)
            }
            
            if githubUser.login == "" {
                Text("Digite seu username")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                Text(githubUser.login)
                    .font(.headline)
            }
            
            if githubUser.bio == "" {
                Text("Digite seu username")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text(githubUser.bio ?? "Voce nao possui uma bio 😾")
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidConversion
}
