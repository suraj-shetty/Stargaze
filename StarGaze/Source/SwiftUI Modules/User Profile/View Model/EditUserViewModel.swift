//
//  EditUserViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 01/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CountryKit
import PhoneNumberKit
import SwiftEmailValidator
import YPImagePicker


class EditUserViewModel: ObservableObject {    
    @Published var name: String = ""
    @Published var bio: String = ""
    @Published var email:String = ""
    @Published var countryCode: String = ""
    @Published var phoneNumber: String = ""
    @Published var picturePath: URL? = nil {
        didSet { //In case there's a change in the image, drop the last image upload details
            self.lastUpload = nil
        }
    }
    
    @Published var error: SGAPIError? = nil
    
    @Published var didUpdate: Bool = false
    @Published var imageUploading: Bool = false
    @Published var profileUpdating: Bool = false
    @Published var storingMedia: Bool = false
    
    private let phoneKit = PhoneNumberKit()
    private var cancellables = Set<AnyCancellable>()
    
    var imageType: SGMimeType? = nil
    
    private var lastUpload: SGUploadResult?
    
    init() {
        if let user = SGAppSession.shared.user.value {
            name        = user.name ?? ""
            bio         = user.bio ?? ""
            email       = user.email ?? ""
            countryCode = user.dialCode ?? ""
            phoneNumber = user.mobileNumber
            
            if let path = user.picture, let url = URL(string: path) {
                picturePath = url
            }
        }
    }
    
    func submit() {
        self.imageUploading = false
        self.profileUpdating = false
        self.didUpdate = false
        self.error = nil
                
        do {
            let request = try validate()
            if let picture = picturePath, picture.isFileURL, let type = imageType {
                uploadImage(image: picture, type: type, request: request)
            }
            else {
                updateProfile(with: request)
            }
        }
        catch let error as SGAPIError {
            self.error = error
        }
        catch {
            self.error = SGAPIError.custom(error.localizedDescription)
        }
    }
    
    private func validate() throws -> EditProfileRequest {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let bio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email
                
        if !name.isEmpty, name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SGAPIError.custom(NSLocalizedString("profile.edit.error.name", comment: ""))
        }
        
        if !bio.isEmpty, bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SGAPIError.custom(NSLocalizedString("profile.edit.error.bio", comment: ""))
        }

//        if Int(countryCode) == nil || phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            throw SGAPIError.custom(NSLocalizedString("profile.edit.error.number", comment: ""))
//        }
        
        if !email.isEmpty, !EmailSyntaxValidator.correctlyFormatted(email) {
            throw SGAPIError.custom(NSLocalizedString("profile.edit.error.email", comment: ""))
        }
        
//        let internationalNumber = "\(countryCode)\(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))"
//        do {
//            _ = try phoneKit.parse(internationalNumber) //Validating phone number
//            //TODO: - Send request
//        }
//        catch {
//            throw SGAPIError.custom(NSLocalizedString("profile.edit.error.number", comment: ""))
//        }
        
        let request = EditProfileRequest(name: name,
                                         bio: bio,
                                         email: email,
                                         picture: lastUpload?.filePath)
        return request
    }
    
    private func uploadImage(image: URL, type: SGMimeType, request: EditProfileRequest) {
        let uploadRequest = SGUploadInfo(type: .profile,
                                         url: image,
                                         mimeType: type)
        self.imageUploading = true
        self.didUpdate = false
        
        SGUploadManager.shared
            .upload(info: uploadRequest)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.imageUploading = false
                    self?.error = error
                    
                case .finished: break
                }
            } receiveValue: {[weak self] result in
                self?.lastUpload = result
                self?.imageUploading = false
                
                var request = request
                request.picture = result.data.subPath
                
                self?.updateProfile(with: request)
            }
            .store(in: &cancellables)
    }
    
    private func updateProfile(with request: EditProfileRequest) {
        self.profileUpdating = true
        
        SGUserService.updateProfile(with: request)
            .delay(for: 2, scheduler: DispatchQueue.main) //Added a delay for the UI to catchup with any previous request (here its the image upload)
            .sink {[weak self] result in
                switch result {
                case .finished: break
                case .failure(let error):
                    self?.profileUpdating = false
                    self?.error = error
                }
            } receiveValue: {[weak self] didSave in
                self?.profileUpdating = false
                self?.didUpdate = didSave
                
                if didSave == false {
                    self?.error = SGAPIError.custom(NSLocalizedString("profile.edit.submit.fail",
                                                                      comment: ""))
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: -
    func saveMedia(media: YPMediaItem) {
        self.storingMedia = true
        let uuid:String = UUID().uuidString
        
        switch media {
        case .photo(let p):
            let image = p.image
            if let data = image.pngData() {
                let fileName = "\(uuid).png"
                self.save(data: data, fileName: fileName) {[weak self] didSave, url in
                    if didSave {
                        DispatchQueue.main.async {
                            self?.picturePath = url
                            self?.imageType = .png
                            self?.storingMedia = false
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self?.storingMedia = false
                            self?.error = SGAPIError.custom(NSLocalizedString("profile.edit.image.save.error", comment: ""))
                        }
                    }
                }
            }
            
            else if let data = image.jpegData(compressionQuality: 1) {
                let fileName = "\(uuid).jpeg"
                self.save(data: data, fileName: fileName) {[weak self] didSave, url in
                    if didSave {
                        DispatchQueue.main.async {
                            self?.picturePath = url
                            self?.imageType = .png
                            self?.storingMedia = false
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self?.storingMedia = false
                            self?.error = SGAPIError.custom(NSLocalizedString("profile.edit.image.save.error", comment: ""))
                        }
                    }
                }
            }
            else { //Unknown image format
                self.storingMedia = false
                self.error = SGAPIError.custom(NSLocalizedString("profile.edit.image.unknown", comment: ""))
            }
            
            
        case .video(_):
            break
        }
        
    }
    
   private func save(data:Data, fileName:String, completion: @escaping (Bool,URL?) -> Void){
        
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(fileName)
        let fileURL = URL(fileURLWithPath: filePath)
                            
        let fileManager = FileManager.default
        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
        dispatchQueue.async {
            //write to URL atomically
            do {
                try data.write(to: fileURL, options: .atomic)
                if fileManager.fileExists(atPath: filePath) {
                    completion (true, fileURL)
                }
                else {
                    completion (false,fileURL)
                }
            }
            catch {
                completion (false,fileURL)
            }
        }
    }
 }
