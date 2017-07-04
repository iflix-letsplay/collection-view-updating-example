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
        let currentItemsContainer: [Container<UIColor>] = items.enumerated().map { Container(indexPath: IndexPath(item: $0, section: 0), item: $1) }
        let newItemsContainer: [Container<UIColor>] = newItems.enumerated().map { Container(indexPath: IndexPath(item: $0, section: 0), item: $1) }

        items = newItems

        collectionView.performBatchUpdates({ [unowned self] _ in
            let delta = currentItemsContainer.count - newItemsContainer.count

            if delta < 0 {
                // we have more items now, need to add a few
                let pathsToInsert = (currentItemsContainer.count..<newItemsContainer.count).map {
                    IndexPath(item: $0, section: 0)
                }
                self.collectionView.insertItems(at: pathsToInsert)

                let pathsToReload = (0..<currentItemsContainer.count).map { IndexPath(item: $0, section: 0) }
                self.collectionView.reloadItems(at: pathsToReload)
            } else if delta > 0 {
                // we have less items now, need to remove a few
                let pathsToRemove = (newItemsContainer.count..<currentItemsContainer.count).map {
                    IndexPath(item: $0, section: 0)
                }
                self.collectionView.deleteItems(at: pathsToRemove)

                let pathsToReload = (0..<currentItemsContainer.count - delta).map { IndexPath(item: $0, section: 0) }
                self.collectionView.reloadItems(at: pathsToReload)
            } else {
                // count is the same, simply relaod
                let pathsToReload = (0..<currentItemsContainer.count).map { IndexPath(item: $0, section: 0) }
                self.collectionView.reloadItems(at: pathsToReload)
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
