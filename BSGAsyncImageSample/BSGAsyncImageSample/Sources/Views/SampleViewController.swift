//
//  SampleViewController.swift
//
//  Created by JechtSh0t on 5/20/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import UIKit

///
/// UI for the sample application.
///
final class SampleViewController: UIViewController {

    // MARK: - Constants -
    
    private struct Constants {
		static let spacing: CGFloat = 12
		static let fontSize: CGFloat = 16
		static let buttonHeight: CGFloat = 50
		static let cacheControlHeight: CGFloat = 30
		static let portraitColumns = 3
        static let imageAspectRatio: CGFloat = 1
    }
    
    // MARK: - Properties -
    
	private var viewModel: SampleViewModel
	
	private lazy var cellSize: CGSize = {
		let availableSpace = min(view.bounds.width, view.bounds.height)
		let emptySpace = Constants.spacing * CGFloat(Constants.portraitColumns + 1)
		let cellWidth = (availableSpace - emptySpace) / CGFloat(Constants.portraitColumns)
		return CGSize(width: cellWidth, height: cellWidth / Constants.imageAspectRatio)
	}()
	
    // MARK: - UI -
    
	private var button: UIButton {
		let button = UIButton()
		button.backgroundColor = button.systemBackgroundInverse
		button.setTitleColor(.systemBackground, for: .normal)
		button.titleLabel?.font = UIFont(name: "Lexend", size: Constants.fontSize)
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.numberOfLines = 0
		button.roundCorners()
		button.addTarget(self, action: #selector(animatePress), for: [.touchDown, .touchDragEnter])
		button.addTarget(self, action: #selector(animateRelease), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
		return button
	}
	
	private var cacheControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl(items: ["None", "Memory", "Disk"])
		segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Lexend", size: Constants.fontSize)!, NSAttributedString.Key.foregroundColor: UIColor.systemBackground], for: .normal)
		segmentedControl.selectedSegmentTintColor = .systemCyan
		segmentedControl.backgroundColor = segmentedControl.systemBackgroundInverse
		
		return segmentedControl
	}()
	
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.spacing
        layout.minimumInteritemSpacing = Constants.spacing
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(SampleCell.self, forCellWithReuseIdentifier: "sampleCell")
        return collectionView
    }()
    
    // MARK: - Setup -
    
	init(viewModel: SampleViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
		
        let activityIndictor = UIActivityIndicatorView()
        activityIndictor.color = collectionView.systemBackgroundInverse
        collectionView.showActivityIndicator(activityIndictor)
        
		viewModel.loadImages {
            DispatchQueue.main.async {
                self.refresh()
            }
		}
    }
	
	private func setup() {
		let refreshButton = button
		refreshButton.setTitle("Refresh\n(Same Images)", for: .normal)
		refreshButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
		view.addSubview(refreshButton)
		refreshButton.translatesAutoresizingMaskIntoConstraints = false
		
		let rerollButton = button
		rerollButton.setTitle("Reroll\n(New Images)", for: .normal)
		rerollButton.addTarget(self, action: #selector(reroll), for: .touchUpInside)
		view.addSubview(rerollButton)
		rerollButton.translatesAutoresizingMaskIntoConstraints = false
		
		cacheControl.selectedSegmentIndex = viewModel.selectedCacheTypeIndex
		cacheControl.addTarget(self, action: #selector(setCacheType), for: .valueChanged)
		view.addSubview(cacheControl)
		cacheControl.translatesAutoresizingMaskIntoConstraints = false
		
		let clearCacheButton = button
		clearCacheButton.setTitle("Clear Cache", for: .normal)
		clearCacheButton.addTarget(self, action: #selector(clearCache), for: .touchUpInside)
		view.addSubview(clearCacheButton)
		clearCacheButton.translatesAutoresizingMaskIntoConstraints = false
		
		collectionView.dataSource = self
		collectionView.delegate = self
		view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(spacing)-[refreshButton]-(spacing)-[rerollButton(refreshButton)]-(spacing)-|", metrics: ["spacing": Constants.spacing], views: ["refreshButton": refreshButton, "rerollButton": rerollButton, "collectionView": collectionView]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(spacing)-[cacheControl]-(spacing)-|", metrics: ["spacing": Constants.spacing], views: ["cacheControl": cacheControl]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(spacing)-[clearCacheButton]-(spacing)-|", metrics: ["spacing": Constants.spacing], views: ["clearCacheButton": clearCacheButton]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(spacing)-[collectionView]-(spacing)-|", metrics: ["spacing": Constants.spacing], views: ["collectionView": collectionView]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[refreshButton(buttonHeight)]-(spacing)-[cacheControl(cacheControlHeight)]-(spacing)-[clearCacheButton(buttonHeight)]-(spacing)-[collectionView]-(spacing)-|", metrics: ["spacing": Constants.spacing, "buttonHeight": Constants.buttonHeight, "cacheControlHeight": Constants.cacheControlHeight], views: ["refreshButton": refreshButton, "cacheControl": cacheControl, "clearCacheButton": clearCacheButton, "collectionView": collectionView]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[rerollButton(buttonHeight)]-(spacing)-[cacheControl(cacheControlHeight)]-(spacing)-[clearCacheButton(buttonHeight)]-(spacing)-[collectionView]-(spacing)-|", metrics: ["spacing": Constants.spacing, "buttonHeight": Constants.buttonHeight, "cacheControlHeight": Constants.cacheControlHeight], views: ["rerollButton": rerollButton, "cacheControl": cacheControl, "clearCacheButton": clearCacheButton, "collectionView": collectionView]))
	}
}

// MARK: - Animation -

extension SampleViewController {
	
	@objc private func animatePress(_ sender: UIButton) {
		animate(sender, transform: CGAffineTransform(scaleX: 0.9, y: 0.9))
	}
	
	@objc private func animateRelease(_ sender: UIButton) {
		animate(sender, transform: .identity)
	}
	
	private func animate(_ sender: UIButton, transform: CGAffineTransform) {
		UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
			sender.transform = transform
		})
	}
}

// MARK: - Collection -

extension SampleViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		viewModel.displayedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sampleCell", for: indexPath) as! SampleCell
		cell.configure(image: viewModel.displayedImages[indexPath.row], imageLoader: viewModel.imageLoader)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return cellSize
    }
}

// MARK: - Controls -

extension SampleViewController {
	
	@objc private func refresh() {
        collectionView.hideActivityIndicator()
		collectionView.reloadData()
	}
	
	@objc private func reroll() {
		viewModel.rollImages()
		refresh()
	}
	
	@objc private func setCacheType(_ sender: UISegmentedControl) {
		viewModel.setCacheType(index: sender.selectedSegmentIndex)
		refresh()
	}
	
	@objc private func clearCache() {
		viewModel.clearCache()
		refresh()
	}
}
