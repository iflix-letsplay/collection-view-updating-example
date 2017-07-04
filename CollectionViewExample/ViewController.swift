import UIKit

struct Container<T> {
    let indexPath: IndexPath
    let item: T
}

class ViewController: UIViewController {

    let reuseIdentifier = "c"

    @IBOutlet var collectionView: UICollectionView!

    let colorsService = ColorService()

    var items: [UIColor] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        items = colorsService.initialColors

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    @IBAction func loadInitialState() {
        updateCollectionView(with: colorsService.initialColors)
    }

    @IBAction func shuffle() {
        updateCollectionView(with: colorsService.shuffle(items))
    }

    @IBAction func replaceAndAddItems() {
        updateCollectionView(with: colorsService.replaceOneAndAddOne(to: items))
    }

    @IBAction func remove() {
        guard items.count > 0 else { return }

        updateCollectionView(with: colorsService.removeOne(from: items))
    }

    func updateCollectionView(with newItems: [UIColor]) {
        let previous: [UIColor: IndexPath] = items
            .enumerated()
            .reduce([UIColor: IndexPath](), { (dictionary, itemWithIndex) -> [UIColor: IndexPath] in
                var newDictionary = dictionary
                newDictionary[itemWithIndex.element] = IndexPath(item: itemWithIndex.offset, section: 0)
                return newDictionary
            })

        let next: [UIColor: IndexPath] = newItems
            .enumerated()
            .reduce([UIColor: IndexPath](), { (dictionary, itemWithIndex) -> [UIColor: IndexPath] in
                var newDictionary = dictionary
                newDictionary[itemWithIndex.element] = IndexPath(item: itemWithIndex.offset, section: 0)
                return newDictionary
            })

        // removed = all the objects that are in previous but not in next
        let removed: [IndexPath] = previous
            .filter { (key, _) -> Bool in
                return next[key] == nil
            }
            .map { (_, indexPath) in return indexPath }

        // inserted = all the objects that are in next but not in previous
        let inserted: [IndexPath] = next
            .filter { (key, _) -> Bool in
                return previous[key] == nil
            }
            .map { (_, indexPath) in return indexPath }

        // moved = all the items that are both in next and previous
        let moved = Array(Set(next.keys).intersection(Set(previous.keys)))

        self.items = newItems

        collectionView.performBatchUpdates({ [unowned self] _ in
            self.collectionView.deleteItems(at: removed)
            self.collectionView.insertItems(at: inserted)

            moved.forEach { item in
                guard
                    let previousIndexPath = previous[item],
                    let nextIndexPath = next[item]
                    else { fatalError() }
                self.collectionView.moveItem(at: previousIndexPath, to: nextIndexPath)
            }
        })
    }
}

extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        cell.contentView.backgroundColor = item
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60.0)
    }
}
