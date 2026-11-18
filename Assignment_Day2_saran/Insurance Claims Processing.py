from collections import deque

class ClaimNode:
    def __init__(self, claim_id):
        self.claim_id = claim_id
        self.left = None
        self.right = None

class ClaimBST:
    def __init__(self):
        self.root = None

    def insert(self, claim_id):
        if not self.root:
            self.root = ClaimNode(claim_id)
            return
        self._insert_recursive(self.root, claim_id)

    def _insert_recursive(self, node, claim_id):
        if claim_id < node.claim_id:
            if node.left is None:
                node.left = ClaimNode(claim_id)
            else:
                self._insert_recursive(node.left, claim_id)
        elif claim_id > node.claim_id:
            if node.right is None:
                node.right = ClaimNode(claim_id)
            else:
                self._insert_recursive(node.right, claim_id)

    def search(self, claim_id):
        return self._search_recursive(self.root, claim_id)

    def _search_recursive(self, node, claim_id):
        if node is None:
            return False
        if claim_id == node.claim_id:
            return True
        elif claim_id < node.claim_id:
            return self._search_recursive(node.left, claim_id)
        return self._search_recursive(node.right, claim_id)

    def inorder(self):
        res = []
        def _traverse(node):
            if node:
                _traverse(node.left)
                res.append(node.claim_id)
                _traverse(node.right)
        _traverse(self.root)
        return res

    def preorder(self):
        res = []
        def _traverse(node):
            if node:
                res.append(node.claim_id)
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
                res.append(node.claim_id)
        _traverse(self.root)
        return res

class ClaimDeduplicator:
    def __init__(self):
        self.seen_claims = {}

    @staticmethod
    def _normalize_key(policy_number, incident_date):
        clean_policy = "".join(policy_number.split()).lower()
        clean_date = "".join(incident_date.split()).lower()
        return (clean_policy, clean_date)

    def check_and_register(self, claim_id, policy_number, incident_date):
        key = self._normalize_key(policy_number, incident_date)
        if key in self.seen_claims:
            existing_id = self.seen_claims[key]
            return f"DUPLICATE DETECTED: {claim_id} matches existing {existing_id} (Key: {key})"
        
        self.seen_claims[key] = claim_id
        return f"REGISTERED: {claim_id} (Key: {key})"

class ApprovalWorkflow:
    def __init__(self):
        self.graph = {}

    def add_transition(self, from_stage, to_stage):
        if from_stage not in self.graph:
            self.graph[from_stage] = []
        if to_stage not in self.graph:
            self.graph[to_stage] = []
        self.graph[from_stage].append(to_stage)

    def shortest_path_bfs(self, start_stage, target_stage):
        if start_stage not in self.graph or target_stage not in self.graph:
            return None
        
        queue = deque([[start_stage]])
        visited = {start_stage}

        while queue:
            path = queue.popleft()
            current = path[-1]

            if current == target_stage:
                return path

            for neighbor in self.graph[current]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(path + [neighbor])
        return None

    def has_cycle_dfs(self):
        state = {node: 0 for node in self.graph}

        def dfs(node):
            state[node] = 1
            for neighbor in self.graph[node]:
                if state[neighbor] == 1:
                    return True  
                if state[neighbor] == 0 and dfs(neighbor):
                    return True
            state[node] = 2
            return False

        for node in self.graph:
            if state[node] == 0:
                if dfs(node):
                    return True
        return False


def longest_spike_run(daily_claims, threshold=100):
    if not daily_claims:
        return 0, []

    left = 0
    max_len = 0
    best_range = (0, -1)

    for right in range(len(daily_claims)):
        if daily_claims[right] <= threshold:
            left = right + 1
        else:
            current_len = right - left + 1
            if current_len > max_len:
                max_len = current_len
                best_range = (left, right)

    if max_len == 0:
        return 0, []
    start, end = best_range
    return max_len, daily_claims[start : end + 1]


def merge_sorted_claims(region_a, region_b):
    i, j = 0, 0
    merged = []

    while i < len(region_a) and j < len(region_b):
        if region_a[i] <= region_b[j]:
            merged.append(region_a[i])
            i += 1
        else:
            merged.append(region_b[j])
            j += 1

    merged.extend(region_a[i:])
    merged.extend(region_b[j:])
    return merged

if __name__ == "__main__":
    print("=== TASK 1: CLAIM BST & TRAVERSALS ===")
    bst = ClaimBST()
    print("Empty BST Inorder:", bst.inorder())
    for cid in ["CLM-500", "CLM-200", "CLM-800", "CLM-100", "CLM-300", "CLM-200"]: 
        bst.insert(cid)
    print("Search CLM-300:", bst.search("CLM-300"))
    print("Search CLM-999:", bst.search("CLM-999"))
    print("Inorder (Sorted):  ", bst.inorder())
    print("Preorder:          ", bst.preorder())
    print("Postorder:         ", bst.postorder())

    print("\n=== TASK 2: DUPLICATE & NEAR-DUPLICATE DETECTION ===")
    dedup = ClaimDeduplicator()
    submissions = [
        ("C101", "POL-8899", "2026-10-10"),
        ("C102", "pol - 8899 ", " 2026-10-10"),  
        ("C103", "POL-8899", "2026-10-11"),    
        ("C104", "POL-8899", "2026-10-10"),    
    ]
    for cid, pol, dt in submissions:
        print(dedup.check_and_register(cid, pol, dt))

    print("\n=== TASK 3: APPROVAL WORKFLOW GRAPH (BFS & DFS) ===")
    workflow = ApprovalWorkflow()
    workflow.add_transition("Registration", "Assessment")
    workflow.add_transition("Assessment", "Surveyor")
    workflow.add_transition("Assessment", "Settlement")  
    workflow.add_transition("Surveyor", "Settlement")

    print("Shortest Path (Registration -> Settlement):", workflow.shortest_path_bfs("Registration", "Settlement"))
    print("Cycle Detected (Before loop):", workflow.has_cycle_dfs())

    workflow.add_transition("Surveyor", "Assessment")
    print("Cycle Detected (After loop): ", workflow.has_cycle_dfs())

    print("\n=== TASK 4: SLIDING WINDOW (CONSECUTIVE DAYS > 100 CLAIMS) ===")
    print("Empty input:", longest_spike_run([]))
    print("No spikes:  ", longest_spike_run([45, 80, 100, 90]))
    claims_log = [85, 110, 145, 130, 95, 105, 160, 180, 210, 90]
    length, streak = longest_spike_run(claims_log)
    print(f"Longest streak: {length} days -> {streak}")

    print("\n=== TASK 5: TWO POINTERS (MERGE SORTED CLAIM LISTS) ===")
    print("Empty lists:", merge_sorted_claims([], []))
    list_north = [101, 104, 108, 115]
    list_south = [102, 104, 110, 120, 125] 
    print("Merged claims:", merge_sorted_claims(list_north, list_south))