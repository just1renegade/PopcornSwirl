//
//  FIRFirestoreService.swift
//  PopcornSwirl
//
//  Created by zsolt on 14/11/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FIRFirestoreService {
    
    private init() {}
    static let shared = FIRFirestoreService()
    
    func configure() {
        FirebaseApp.configure()
    }
    private func reference(to collectionReference: FIRCollectionReference) -> CollectionReference {
        return Firestore.firestore().collection(collectionReference.rawValue)
    }
    func create<T: Encodable>(for encodableObject: T, in collectionReference: FIRCollectionReference) {
        do {
            let json = try encodableObject.toJson(excluding: ["documentId"])
            reference(to: collectionReference).addDocument(data: json)
        } catch {
            print(error.localizedDescription)
        }
    }
    func read<T: Decodable>(from collectionReference: FIRCollectionReference, returning objectType: T.Type, completion: @escaping([T]) -> Void) {
        
        reference(to: collectionReference).addSnapshotListener { (snapshot, _) in
            
            guard let snapshot = snapshot else {return}
            
            do {
                var objects = [T]()
                for document in snapshot.documents {
                    let object = try document.decode(as: objectType.self)
                    objects.append(object)
                }
                completion(objects)
            } catch {
                print (error.localizedDescription)
            }
        }
    }
    func update<T: Encodable & Identifiable>(for encodableObject: T, in collectionReference: FIRCollectionReference) {
        
        do {
            let json = try encodableObject.toJson(excluding: ["documentId"])
            guard let id = encodableObject.documentId else { throw MyError.encodingError }
            reference(to: collectionReference).document(id).setData(json)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    func delete<T: Identifiable>(_ identifiableObject: T, in collectionReference: FIRCollectionReference) {
        
        do {
            guard let id = identifiableObject.documentId else { throw MyError.encodingError }
            reference(to: collectionReference).document(id).delete()
            
        } catch {
            print(error.localizedDescription)
        }
    }
}


