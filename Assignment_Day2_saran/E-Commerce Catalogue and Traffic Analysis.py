import time
import random
from collections import deque

class CategoryNode:
    def __init__(self, category):
        self.category = category
        self.left = None
        self.right = None

class CategoryBST:
    def __init__(self):
        self.root = None

    def insert(self, category):
        if not self.root:
            self.root = CategoryNode(category)
            return
        self._insert_recursive(self.root, category)

    def _insert_recursive(self, node, category):
        if category < node.category:
            if node.left is None:
                node.left = CategoryNode(category)
            else:
                self._insert_recursive(node.left, category)
        elif category > node.category:
            if node.right is None:
                node.right = CategoryNode(category)
            else:
                self._insert_recursive(node.right, category)

    def search(self, category):
        return self._search_recursive(self.root, category)

    def _search_recursive(self, node, category):
        if node is None:
            return False
        if category == node.category:
            return True
        elif category < node.category:
            return self._search_recursive(node.left, category)
        return self._search_recursive(node.right, category)

    def inorder(self):
        res = []
        def _traverse(node):
            if node:
                _traverse(node.left)
                res.append(node.category)
                _traverse(node.right)
        _traverse(self.root)
        return res

    def preorder(self):
        res = []
        def _traverse(node):
            if node:
                res.append(node.category)
                _traverse(node.left)
                _traverse(node.right)
        _traverse(self.root)
        return res

    def postorder(self):
        res = []
        def _traverse(node):
            if node:
                _traverse(node.left)
                _traverse(node.right)
                res.append(node.category)
        _traverse(self.root)
        return res

class ChainedHashTable:
    def __init__(self, capacity=10):
        self.capacity = capacity
        self.buckets = [[] for _ in range(capacity)]

    def _hash(self, key):
        return sum(ord(ch) for ch in str(key)) % self.capacity

    def insert(self, sku, product_info):
        idx = self._hash(sku)
        bucket = self.buckets[idx]
        for i, (k, _) in enumerate(bucket):
            if k == sku:
                bucket[i] = (sku, product_info)
                return idx
        bucket.append((sku, product_info))
        return idx

    def lookup(self, sku):
        idx = self._hash(sku)
        for k, v in self.buckets[idx]:
            if k == sku:
                return v
        return None


class DeploymentGraph:
    def __init__(self):
        self.adj = {}
        self.in_degree = {}

    def add_dependency(self, service, depends_on):
        for node in (service, depends_on):
            if node not in self.adj:
                self.adj[node] = []
                self.in_degree[node] = 0
        self.adj[depends_on].append(service)
        self.in_degree[service] += 1

    def get_deployment_order_bfs(self):
        in_deg = dict(self.in_degree)
        queue = deque([node for node, deg in in_deg.items() if deg == 0])
        order = []

        while queue:
            current = queue.popleft()
            order.append(current)
            for neighbor in self.adj[current]:
                in_deg[neighbor] -= 1
                if in_deg[neighbor] == 0:
                    queue.append(neighbor)

        if len(order) != len(self.adj):
            return None, True  
        return order, False

    def has_cycle_dfs(self):
        state = {node: 0 for node in self.adj}

        def dfs(node):
            state[node] = 1
            for neighbor in self.adj[node]:
                if state[neighbor] == 1:
                    return True
                if state[neighbor] == 0 and dfs(neighbor):
                    return True
            state[node] = 2
            return False

        return any(dfs(node) for node in self.adj if state[node] == 0)

def busiest_3hour_window(rpm_24h):
    window_size = 180
    if len(rpm_24h) < window_size:
        return None

    current_sum = sum(rpm_24h[:window_size])
    max_sum = current_sum
    best_start_min = 0

    for i in range(window_size, len(rpm_24h)):
        current_sum += rpm_24h[i] - rpm_24h[i - window_size]
        if current_sum > max_sum:
            max_sum = current_sum
            best_start_min = i - window_size + 1

    start_hr, start_m = divmod(best_start_min, 60)
    end_hr, end_m = divmod(best_start_min + window_size, 60)
    time_span = f"{start_hr:02d}:{start_m:02d} to {end_hr:02d}:{end_m:02d}"
    return best_start_min, time_span, max_sum

def find_gift_card_pairs(sorted_orders, target):
    left = 0
    right = len(sorted_orders) - 1
    pairs = []

    while left < right:
        current_sum = sorted_orders[left] + sorted_orders[right]
        if current_sum == target:
            pairs.append((sorted_orders[left], sorted_orders[right]))
            left += 1
            right -= 1
            while left < right and sorted_orders[left] == sorted_orders[left - 1]:
                left += 1
            while left < right and sorted_orders[right] == sorted_orders[right + 1]:
                right -= 1
        elif current_sum < target:
            left += 1
        else:
            right -= 1

    return pairs

if __name__ == "__main__":
    print("=== TASK 1: PRODUCT CATEGORIES BST (15 CATEGORIES) ===")
    categories = [
        "Electronics", "Apparel", "Home", "Books", "Toys",
        "Sports", "Beauty", "Automotive", "Grocery", "Furniture",
        "Jewelry", "Garden", "PetSupplies", "Office", "Music"
    ]
    cat_bst = CategoryBST()
    for c in categories:
        cat_bst.insert(c)

    print("Search 'Beauty':", cat_bst.search("Beauty"))
    print("Search 'Gaming':", cat_bst.search("Gaming"))
    print("Inorder:  ", cat_bst.inorder())
    print("Preorder: ", cat_bst.preorder())
    print("Postorder:", cat_bst.postorder())

    print("\n=== TASK 2: HASH TABLE WITH CHAINING & 100,000 SKU BENCHMARK ===")
    small_ht = ChainedHashTable(capacity=5)
    b1 = small_ht.insert("SKU-AB", "Wireless Mouse")
    b2 = small_ht.insert("SKU-BA", "Mechanical Keyboard")
    print(f"Collision Demo -> Bucket {b1} contents:", small_ht.buckets[b1])

    num_skus = 100_000
    skus = [f"SKU-{i:06d}" for i in range(num_skus)]
    custom_ht = ChainedHashTable(capacity=10_000) 
    builtin_dict = {}

    for s in skus:
        custom_ht.insert(s, 99.99)
        builtin_dict[s] = 99.99

    t0 = time.perf_counter()
    for s in skus:
        _ = custom_ht.lookup(s)
    custom_time = time.perf_counter() - t0

    t0 = time.perf_counter()
    for s in skus:
        _ = builtin_dict.get(s)
    builtin_time = time.perf_counter() - t0

    print(f"100,000 Lookups - Custom Chained Hash Table: {custom_time:.4f}s")
    print(f"100,000 Lookups - Built-in dict (Hash Map):  {builtin_time:.4f}s")

    print("\n=== TASK 3: MICROSERVICE DEPLOYMENT DEPENDENCIES ===")
    deploy_graph = DeploymentGraph()
    deploy_graph.add_dependency("cart", "pricing")
    deploy_graph.add_dependency("cart", "auth")
    deploy_graph.add_dependency("pricing", "inventory")
    deploy_graph.add_dependency("pricing", "catalog")
    deploy_graph.add_dependency("inventory", "database")

    order, has_cycle = deploy_graph.get_deployment_order_bfs()
    print("Valid Deployment Order (BFS Kahn's):", " -> ".join(order))
    print("Circular Dependency Detected (DFS): ", deploy_graph.has_cycle_dfs())

    deploy_graph.add_dependency("database", "cart")
    _, has_cycle_after = deploy_graph.get_deployment_order_bfs()
    print("Circular Dependency After Loop (BFS/DFS):", has_cycle_after, "/", deploy_graph.has_cycle_dfs())

    print("\n=== TASK 4: BUSIEST 3-HOUR TRAFFIC WINDOW (24 HOURS / 1440 MINS) ===")
    random.seed(42)
    traffic_24h = [random.randint(100, 300) for _ in range(1440)]
    for m in range(1140, 1320):
        traffic_24h[m] = random.randint(800, 1000)

    start_min, span, peak_reqs = busiest_3hour_window(traffic_24h)
    print(f"Busiest 3-Hour Window: {span} (starts at minute {start_min}) -> {peak_reqs:,} total requests")

    print("\n=== TASK 5: GIFT-CARD TARGET PAIRS (TWO POINTERS) ===")
    order_values = [15, 25, 30, 45, 50, 55, 70, 75, 85]
    gift_card = 100
    print(f"Sorted Orders: {order_values}")
    print(f"Pairs summing to {gift_card}: {find_gift_card_pairs(order_values, gift_card)}")