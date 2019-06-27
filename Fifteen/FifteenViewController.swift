import UIKit

class FifteenViewController: UIViewController {
    
    @IBOutlet weak var pole: UICollectionView!
    
    private var numberCell = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", " "]
    private var firstIndexPath: IndexPath?
    private var secondIndexPath: IndexPath?
    private var longGesture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longGesture = UIPanGestureRecognizer(target: self, action: #selector(myGesture))
        pole.addGestureRecognizer(longGesture)
        self.title = "Fifteen"
        
        pole.register(FifteenCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        //        pole.allowsMultipleSelection = true
        
        numberCell.shuffle()
    }
    
    @objc func myGesture (param: UIPanGestureRecognizer) {
        
        switch param.state {
            
        case .began: guard let selectedIndexPath = pole.indexPathForItem(at: param.location(in: pole)) else { break }
        pole.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case .changed:
            pole.updateInteractiveMovementTargetPosition(param.location(in: param.view!))
            
        case .ended:
            pole.endInteractiveMovement()
            
        default:
            pole.cancelInteractiveMovement()
        }
    }
    
    @IBAction func move(_ sender: UIButton) {
        guard let start = firstIndexPath, let end = secondIndexPath else { return }
        
        pole.performBatchUpdates({
            pole.moveItem(at: start, to: end)
            pole.moveItem(at: end, to: start)
            
        }) { (finished) in
            self.pole.deselectItem(at: start, animated: true)
            self.pole.deselectItem(at: end, animated: true)
            self.firstIndexPath = nil
            self.secondIndexPath = nil
            self.numberCell.swapAt(start.item, end.item)
        }
    }
}

extension FifteenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        var emptyId = 0
        
        for i in 0..<numberCell.count {
            if numberCell[i] == " " {
                emptyId = i
            }
        }
        
        if indexPath.item == emptyId - 1 || indexPath.item == emptyId + 1 {
            return true
        }
        
        if indexPath.item == emptyId - 4 || indexPath.item == emptyId + 4 {
            if emptyId - 4 >= 0 && emptyId + 4 <= 15 {
                
                let temp = numberCell.remove(at: 0)
                numberCell.insert(temp, at: 1)
                pole.reloadData()
                return true
            }
        }
        
        
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = numberCell.remove(at: sourceIndexPath.item)
        numberCell.insert(temp, at: destinationIndexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FifteenCollectionViewCell
        cell.number.text = numberCell[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if firstIndexPath == nil {
            firstIndexPath = indexPath
            collectionView.selectItem(at: firstIndexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
        } else if secondIndexPath == nil {
            secondIndexPath = indexPath
            collectionView.selectItem(at: secondIndexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
        } else {
            collectionView.deselectItem(at: secondIndexPath!, animated: true)
            secondIndexPath = indexPath
            collectionView.selectItem(at: secondIndexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath == firstIndexPath {
            firstIndexPath = nil
        } else if indexPath == secondIndexPath {
            secondIndexPath = nil
        }
    }
}
