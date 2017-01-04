//
//  PokemonDetailsViewController.swift
//  Pokedex
//
//  Created by Nikolas Burk on 04/01/17.
//  Copyright © 2017 Nikolas Burk. All rights reserved.
//

import UIKit
import Alamofire
import Apollo

class PokemonDetailsViewController: UIViewController, UINavigationControllerDelegate {
  
  enum EditingState {
    case editing
    case notEditing
  }
  
  @IBOutlet weak var pokemonImageView: UIImageView!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var urlTextField: UITextField!
  @IBOutlet weak var editAndSaveButton: UIButton!
  @IBOutlet weak var saveActivityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var deleteActivityIndictor: UIActivityIndicatorView!
  
  var pokemonDetails: PokemonDetails? {
    didSet {
      updateUI()
    }
  }
  
  var deletedPokemonWithId: ((GraphQLID) -> ())?
  var updatedPokemonWithDetails: ((PokemonDetails) -> ())?

  var editingState: EditingState = .notEditing {
    didSet {
      nameTextField.isEnabled = editingState == .editing
      urlTextField.isEnabled = editingState == .editing
      editAndSaveButton.setTitle(editingState == .editing ? "Save" : "Edit", for: .normal)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Details"
    updateUI()
    nameTextField.isEnabled = false
    urlTextField.isEnabled = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let pokemonDetails = self.pokemonDetails {
      updatedPokemonWithDetails?(pokemonDetails)
    }
  }
  
  func updateUI() {
    // make sure UI elements are there to prevent this from being called before viewDidLoad
    guard let nameTextField = self.nameTextField,
      let urlTextField = self.urlTextField else {
        return
    }
    nameTextField.text = pokemonDetails?.name
    urlTextField.text = pokemonDetails?.url
    loadImage()
    
  }
  
  func loadImage() {
    if let pokemonURL = pokemonDetails?.url {
      Alamofire.request(pokemonURL).responseImage { response in
        if let image = response.result.value {
          self.pokemonImageView.image = image
        }
      }
    }
    else {
      print(#function, "ERROR: No URL for \(pokemonDetails?.name)")
    }
  }
  
  @IBAction func editAndSaveButtonPressed() {
    if editingState == .notEditing {
      editingState = .editing
    }
    else {
      guard let name = nameTextField.text, nameTextField.text!.characters.count > 0,
        let url = urlTextField.text, urlTextField.text!.characters.count > 0,
        let id = pokemonDetails?.id else {
          print(#function, "ERROR: No data provided")
          return
      }
      
      saveActivityIndicator.startAnimating()
      
      let updatePokemonMutation = UpdatePokemonMutation(id: id, name: name, url: url)
      apollo.perform(mutation: updatePokemonMutation) { [unowned self] result, error in
        
        if let error = error {
          print(#function, "ERROR: Could not update Pokemon (\(error))")
        }
        else if let pokemonDetails = result?.data?.updatePokemon?.fragments.pokemonDetails {
          self.pokemonDetails = pokemonDetails
          self.saveActivityIndicator.stopAnimating()
          self.editingState = .notEditing
        }
        
      }
      
    }
  }
  
  @IBAction func deleteButtonPressed() {
    guard let id = pokemonDetails?.id else {
      print(#function, "ERROR: No ID for Pokemon to be deleted")
      return
    }
    deleteActivityIndictor.startAnimating()
    let deleteMutation = DeletePokemonMutation(id: id)
    apollo.perform(mutation: deleteMutation) { [unowned self] result, error in
      self.deleteActivityIndictor.stopAnimating()
      if let error = error {
        print(#function, "ERROR: Could not delete Pokemon (\(error))")
      }
      else {
        self.deletedPokemonWithId?(id)
        let _ = self.navigationController?.popViewController(animated: true)
      }
    }
  }
  
}
