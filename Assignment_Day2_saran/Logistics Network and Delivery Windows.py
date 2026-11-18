from collections import deque

class HubNode:
    def __init__(self, code):
        self.code = code
        self.left = None
        self.right = None

class HubBST:
    def __init__(self):
        self.root = None

    def insert(self, code):
        if not self.root:
            self.root = HubNode(code)
            return
        self._insert_recursive(self.root, code)

    def _insert_recursive(self, node, code):
        if code < node.code:
            if node.left is None:
                node.left = HubNode(code)
            else:
                self._insert_recursive(node.left, code)
        elif code > node.code:
            if node.right is None:
                node.right = HubNode(code)
            else:
                self._insert_recursive(node.right, code)

    def search(self, code):
        return self._search_recursive(self.root, code)

    def _search_recursive(self, node, code):
        if node is None:
            return False
        if code == node.code:
            return True
        elif code < node.code:
            return self._search_recursive(node.left, code)
        else:
            return self._search_recursive(node.right, code)

    def get_height(self, node="ROOT"):
        if node == "ROOT":
            node = self.root
        if node is None:
            return -1  # Height measured in edges (-1 for empty, 0 for single node)
        return 1 + max(self.get_height(node.left), self.get_height(node.right))

class ParcelTracker:
    def __init__(self):
        # Maps tracking_id -> set of hubs where the parcel was scanned
        self.scan_history = {}

    def record_scan(self, tracking_id, hub_code):
        if tracking_id not in self.scan_history:
            self.scan_history[tracking_id] = set()
        
        if hub_code in self.scan_history[tracking_id]:
            return f"ALERT: Duplicate scan detected for {tracking_id} at hub {hub_code}!"
        
        self.scan_history[tracking_id].add(hub_code)
        return f"OK: {tracking_id} scanned at {hub_code}."

    def lookup_parcel(self, tracking_id):
        return self.scan_history.get(tracking_id, "Tracking ID not found.")

class LogisticsNetwork:
    def __init__(self, adj_list):
        self.graph = adj_list

    def shortest_hops_bfs(self, start, destination):
        if start not in self.graph or destination not in self.graph:
            return None
        
        queue = deque([[start]])
        visited = {start}

        while queue:
            path = queue.popleft()
            current_hub = path[-1]

            if current_hub == destination:
                return path

            for neighbor in self.graph[current_hub]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(path + [neighbor])
        return None

    def reachable_hubs_dfs(self, depot):
        visited = set()
        reachable = []

        def dfs(hub):
            visited.add(hub)
            reachable.append(hub)
            for neighbor in self.graph.get(hub, []):
                if neighbor not in visited:
                    dfs(neighbor)

        if depot in self.graph:
            dfs(depot)
        return reachable

def max_4hour_average(hourly_counts):
    k = 4
    if len(hourly_counts) < k:
        return None

    window_sum = sum(hourly_counts[:k])
    max_sum = window_sum
    best_start_idx = 0

    for i in range(k, len(hourly_counts)):
        window_sum += hourly_counts[i] - hourly_counts[i - k]
        if window_sum > max_sum:
            max_sum = window_sum
            best_start_idx = i - k + 1

    best_window = hourly_counts[best_start_idx : best_start_idx + k]
    return best_start_idx, best_window, max_sum / k

def is_route_palindrome(route_desc):
    left = 0
    right = len(route_desc) - 1

    while left < right:
        while left < right and not route_desc[left].isalnum():
            left += 1
        while left < right and not route_desc[right].isalnum():
            right -= 1

        if route_desc[left].lower() != route_desc[right].lower():
            return False

        left += 1
        right -= 1

    return True

if __name__ == "__main__":
    print("--- TASK 1: HUB BST & HEIGHT ---")
    mixed_hubs = ["DEL", "BOM", "MAA", "BLR", "CCU", "HYD", "PNQ"]
    bst_mixed = HubBST()
    for hub in mixed_hubs:
        bst_mixed.insert(hub)

    print("Search 'HYD':", bst_mixed.search("HYD"))
    print("Search 'GOI':", bst_mixed.search("GOI"))
    print("Tree Height (Mixed Order):", bst_mixed.get_height())

    bst_sorted = HubBST()
    for hub in sorted(mixed_hubs):
        bst_sorted.insert(hub)
    print("Tree Height (Sorted Order):", bst_sorted.get_height())

    print("\n--- TASK 2: PARCEL TRACKING & DUPLICATE DETECTION ---")
    tracker = ParcelTracker()
    scans = [
        ("TRK1001", "DEL"),
        ("TRK1001", "BOM"),
        ("TRK1002", "BLR"),
        ("TRK1001", "BOM"),
    ]
    for tid, hub in scans:
        print(tracker.record_scan(tid, hub))
    print("Lookup TRK1001:", tracker.lookup_parcel("TRK1001"))

    print("\n--- TASK 3: 10-HUB NETWORK (BFS & DFS) ---")
    hub_network = {
        "DEL": ["BOM", "BLR", "CCU", "LKO"],
        "BOM": ["DEL", "PNQ", "AMD"],
        "BLR": ["DEL", "MAA", "HYD"],
        "CCU": ["DEL"],
        "LKO": ["DEL"],
        "PNQ": ["BOM"],
        "AMD": ["BOM"],
        "MAA": ["BLR"],
        "HYD": ["BLR"],
        "GOI": []  
    }
    network = LogisticsNetwork(hub_network)
    route = network.shortest_hops_bfs("PNQ", "MAA")
    print(f"Fewest hops (PNQ -> MAA): {' -> '.join(route)} ({len(route)-1} hops)")
    print("Reachable from Central Depot (DEL):", network.reachable_hubs_dfs("DEL"))

    print("\n--- TASK 4: SLIDING WINDOW (4-HOUR AVERAGE) ---")
    hourly_parcels = [120, 150, 180, 210, 340, 410, 390, 360, 250, 190, 140, 110]
    start_hr, window_vals, max_avg = max_4hour_average(hourly_parcels)
    print(f"Peak 4-hour window starts at Hour {start_hr}: {window_vals}")
    print(f"Highest 4-hour average: {max_avg:.2f} parcels/hour")

    print("\n--- TASK 5: TWO POINTERS (ROUTE PALINDROME) ---")
    route_1 = "DEL - BOM -> BLR <- MOB - LED"
    route_2 = "DEL -> BOM -> MAA"
    print(f"'{route_1}' is palindrome: {is_route_palindrome(route_1)}")
    print(f"'{route_2}' is palindrome: {is_route_palindrome(route_2)}")