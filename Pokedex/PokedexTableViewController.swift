//
//  PokedexTableViewController.swift
//  Pokedex
//
//  Created by Nikolas Burk on 03/01/17.
//  Copyright © 2017 Nikolas Burk. All rights reserved.
//

import UIKit
import Apollo

class PokedexTableViewController: UITableViewController {
  
  var trainer: TrainerQuery.Data.Trainer?
  var ownedPokemons: [PokemonDetails] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  
  
  // MARK: View Controller Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Pokedex"
    
    apollo.fetch(query: TrainerQuery(name: "Nikolas"), completionHandler: { (result: GraphQLResult<TrainerQuery.Data>?, error: Error?) in
      guard let trainer = result?.data?.trainer else {
        print(#function, "ERROR: Did not fetch trainer")
        return
      }
      self.trainer = trainer
      if let ownedPokemons = trainer.ownedPokemons {
        self.ownedPokemons = ownedPokemons.map { ownedPokemon in
          return ownedPokemon.fragments.pokemonDetails
        }
      }
    })
    
  }
  
  
  // MARK: Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ownedPokemons.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PokemonCell
    let pokemonDetails = ownedPokemons[indexPath.row]
    cell.pokemonDetails = pokemonDetails
    return cell
  }
  
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "AddPokemonSegue" {
      if let trainer = trainer  {
        let addPokemonViewController = segue.destination as! AddPokemonViewController
        addPokemonViewController.newPokemonAdded = { [unowned self] in self.ownedPokemons.append($0) }
        addPokemonViewController.trainer = trainer
      }
      else {
        print(#function, "ERROR: No trainer who could fetch a Pokemon")
      }
    }
    else if segue.identifier == "PokemonDetailsSegue" {
      if let selectedRow = tableView.indexPathForSelectedRow?.row {
        let pokemonDetails = ownedPokemons[selectedRow]
        let pokemonDetailsViewController = segue.destination as! PokemonDetailsViewController
        pokemonDetailsViewController.pokemonDetails = pokemonDetails
        pokemonDetailsViewController.deletedPokemonWithId = { [unowned self] id in
          self.ownedPokemons = self.ownedPokemons.filter { ownedPokemon in
            ownedPokemon.id != id
          }
        }
        pokemonDetailsViewController.updatedPokemonWithDetails = { [unowned self] pokemonDetails in
          if let index = self.ownedPokemons.index(where: { pokemonDetailsInArray in
            return pokemonDetailsInArray.id == pokemonDetails.id
          }) {
            self.ownedPokemons[index] = pokemonDetails
          }
          
        }
      }
    }
    
  }
  
}




