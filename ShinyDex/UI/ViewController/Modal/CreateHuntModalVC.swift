//
//  CreateHuntModalVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 26/04/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class CreateHuntModalVC: UIViewController, UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate
{
	let searchController = UISearchController(searchResultsController: nil)

	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var currentHuntService: CurrentHuntService!
	var filteredPokemon = [Pokemon]()
	var allPokemon: [Pokemon]!
	var newHunt = Hunt(name: "New Hunt", pokemon: [Pokemon]())
	var currentHunts: [Hunt]!

	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad()
	{
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		textField.delegate = self
		setUpSearchController()
    }

	fileprivate func setUpSearchController()
	{
		searchController.searchResultsUpdater = self

		searchController.obscuresBackgroundDuringPresentation = false

		searchController.searchBar.placeholder = "Search Pokédex"

		searchController.definesPresentationContext = true

		searchController.view.backgroundColor = .red

		navigationItem.searchController = searchController

		definesPresentationContext = true
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isFiltering() ? filteredPokemon.count : allPokemon.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "createHuntCell", for: indexPath) as! CreateHuntCell

		let pokemon = getSelectedPokemon(index: indexPath.row)

		cell.spriteImageView.image = pokemon.shinyImage
		cell.nameLabel.text = pokemon.name
		cell.numberLabel.text = "No. \(String(pokemon.number + 1))"
		cell.nameLabel.font = fontSettingsService.getSmallFont()
		cell.numberLabel.font = fontSettingsService.getExtraSmallFont()
		cell.nameLabel.textColor = colorService!.getTertiaryColor()
		cell.numberLabel.textColor = colorService!.getTertiaryColor()
		cell.isUserInteractionEnabled = !pokemon.isBeingHunted

        return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let pokemon = getSelectedPokemon(index: indexPath.row)
		pokemon.isBeingHunted = true
		newHunt.pokemon.append(pokemon)
		newHunt.names.append(pokemon.name)
	}

	func filterContentForSearchText(_ searchText: String, scope: String = "Regular")
	{
		filteredPokemon = allPokemon.filter( {(pokemon : Pokemon) -> Bool in

			let doesCategoryMatch = (scope == "Shinydex") || (scope == pokemon.caughtDescription)

			if searchBarIsEmpty()
			{
				return doesCategoryMatch
			}

			return doesCategoryMatch && pokemon.name.lowercased().contains(searchText.lowercased())
	})
		tableView.reloadData()
	}

	func isFiltering() -> Bool
	{
		let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
		return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
	}

	func searchBarIsEmpty() -> Bool
	{
		return searchController.searchBar.text?.isEmpty ?? true
	}

	func addToCurrenHuntPressed(_ sender: UIButton)
	{
		if let indexPath = getCurrentCellIndexPath(sender)
		{
			let pokemon = getSelectedPokemon(index: indexPath.row)
			newHunt.pokemon.append(pokemon)
			newHunt.names.append(pokemon.name)
		}
	}

	func getCurrentCellIndexPath(_ sender : UIButton) -> IndexPath?
	{
		let buttonPosition = sender.convert(CGPoint.zero, to : tableView)
		if let indexPath = tableView.indexPathForRow(at: buttonPosition)
		{
			return indexPath
		}
		return nil
	}

	@IBAction func confirmPressed(_ sender: Any)
	{
		newHunt.name = textField.text ?? "New Hunt"
		newHunt.pokemon = newHunt.pokemon.sorted(by: { $0.number < $1.number})
		currentHuntService.save(hunt: newHunt)
		currentHunts.append(newHunt)
		performSegue(withIdentifier: "confirmUnwindSegue", sender: self)
	}

	@IBAction func cancelPressed(_ sender: Any)
	{
		for pokemon in newHunt.pokemon
		{
			pokemon.isBeingHunted = false
		}
		dismiss(animated: true)
	}

	fileprivate func getSelectedPokemon(index: Int) -> Pokemon
	{
		if isFiltering()
		{
			return filteredPokemon[index]
		}
		else
		{
			return allPokemon[index]
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
        self.view.endEditing(true)
        return false
    }
}
