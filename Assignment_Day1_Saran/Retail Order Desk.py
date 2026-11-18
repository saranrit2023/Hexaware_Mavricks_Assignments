import csv
import random
import time
from collections import deque
from datetime import datetime, timedelta

def generate_orders_csv(filename="orders.csv", num_records=50000):
    base_time = datetime(2026, 10, 14, 9, 0, 0)
    with open(filename, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["orderId", "customerId", "amount", "createdAt"])
        for i in range(1, num_records + 1):
            order_id = f"ORD-{100000 + i}"
            cust_id = f"CUST-{random.randint(1000, 9999)}"
            amount = round(random.uniform(10.0, 5000.0), 2)
            created_at = (base_time + timedelta(seconds=i * 2)).strftime("%Y-%m-%d %H:%M:%S")
            writer.writerow([order_id, cust_id, amount, created_at])
            if i % 10000 == 0:
                dup_time = (base_time + timedelta(seconds=i * 2 + 15)).strftime("%Y-%m-%d %H:%M:%S")
                writer.writerow([f"ORD-{100000 + i}-DUP", cust_id, amount, dup_time])


def load_orders(filename="orders.csv"):
    orders = []
    with open(filename, mode="r") as file:
        reader = csv.DictReader(file)
        for row in reader:
            row["amount"] = float(row["amount"])
            orders.append(row)
    return orders

def linear_search(orders, target_id):
    for order in orders:
        if order["orderId"] == target_id:
            return order
    return None


def binary_search(sorted_orders, target_id):
    low, high = 0, len(sorted_orders) - 1
    while low <= high:
        mid = (low + high) // 2
        if sorted_orders[mid]["orderId"] == target_id:
            return sorted_orders[mid]
        elif sorted_orders[mid]["orderId"] < target_id:
            low = mid + 1
        else:
            high = mid - 1
    return None


def run_task_1(orders):
    print("\n--- TASK 1: Searching (50,000 Records) ---")
    # Sort by orderId first for binary search
    sorted_orders = sorted(orders, key=lambda x: x["orderId"])
    target_id = sorted_orders[-500]["orderId"] 

    start = time.perf_counter()
    for _ in range(1000):
        linear_search(sorted_orders, target_id)
    linear_time = (time.perf_counter() - start) * 1000

    start = time.perf_counter()
    for _ in range(1000):
        binary_search(sorted_orders, target_id)
    binary_time = (time.perf_counter() - start) * 1000

    print(f"Target Order: {target_id}")
    print(f"Linear Search (1,000 lookups): {linear_time:.3f} ms")
    print(f"Binary Search (1,000 lookups): {binary_time:.3f} ms")

def bubble_sort_desc(arr):
    data = arr[:]
    n = len(data)
    for i in range(n):
        swapped = False
        for j in range(0, n - i - 1):
            if data[j]["amount"] < data[j + 1]["amount"]:
                data[j], data[j + 1] = data[j + 1], data[j]
                swapped = True
        if not swapped:
            break
    return data


def merge_sort_desc(arr):
    if len(arr) <= 1:
        return arr
    mid = len(arr) // 2
    left = merge_sort_desc(arr[:mid])
    right = merge_sort_desc(arr[mid:])
    return _merge(left, right)


def _merge(left, right):
    result = []
    i = j = 0
    while i < len(left) and j < len(right):
        if left[i]["amount"] >= right[j]["amount"]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    result.extend(left[i:])
    result.extend(right[j:])
    return result


def run_task_2(orders):
    print("\n--- TASK 2: Sorting by Amount Descending (10,000 Records) ---")
    subset = orders[:10000]

    start = time.perf_counter()
    bubble_sort_desc(subset)
    bubble_time = time.perf_counter() - start

    start = time.perf_counter()
    merge_sort_desc(subset)
    merge_time = time.perf_counter() - start

    start = time.perf_counter()
    sorted(subset, key=lambda x: x["amount"], reverse=True)
    builtin_time = time.perf_counter() - start

    print(f"Bubble Sort O(n^2)   : {bubble_time:.4f} s")
    print(f"Merge Sort O(n log n): {merge_time:.4f} s")
    print(f"Built-in Timsort     : {builtin_time:.4f} s")

def detect_duplicates(orders):
    seen = {} 
    duplicates = []
    for order in orders:
        minute_bucket = order["createdAt"][:16] 
        signature = (order["customerId"], order["amount"], minute_bucket)
        if signature in seen:
            duplicates.append((seen[signature], order["orderId"], signature))
        else:
            seen[signature] = order["orderId"]
    return duplicates


def run_task_3(orders):
    print("\n--- TASK 3: Duplicate Order Detection ---")
    dups = detect_duplicates(orders)
    print(f"Total Duplicates Flagged: {len(dups)}")
    for orig, dup, sig in dups[:3]:
        print(f"  Original: {orig} | Duplicate: {dup} | Key: {sig}")


class CustomStack:
    def __init__(self):
        self._items = []

    def push(self, item):
        self._items.append(item)

    def pop(self):
        if self.is_empty():
            raise IndexError("Pop from empty stack")
        return self._items.pop()

    def is_empty(self):
        return len(self._items) == 0


class Node:
    def __init__(self, value):
        self.value = value
        self.next = None


class CustomQueue:
    """Linked-list backed FIFO Queue ensuring true O(1) enqueue and dequeue."""
    def __init__(self):
        self.head = None
        self.tail = None

    def enqueue(self, item):
        new_node = Node(item)
        if self.tail:
            self.tail.next = new_node
        self.tail = new_node
        if not self.head:
            self.head = new_node

    def dequeue(self):
        if not self.head:
            raise IndexError("Dequeue from empty queue")
        val = self.head.value
        self.head = self.head.next
        if not self.head:
            self.tail = None
        return val


def run_task_4():
    print("\n--- TASK 4: Custom Stack & Queue vs Built-ins ---")
    undo_stack = CustomStack()
    undo_stack.push("Edit 1: Changed qty 1 -> 2")
    undo_stack.push("Edit 2: Applied coupon SAVE10")
    print(f"Custom Stack Undo -> {undo_stack.pop()}")

    builtin_stack = []
    builtin_stack.append("Edit 1: Changed qty 1 -> 2")
    builtin_stack.append("Edit 2: Applied coupon SAVE10")
    print(f"Built-in list Undo -> {builtin_stack.pop()}")

    dispatch_q = CustomQueue()
    dispatch_q.enqueue("ORD-100001")
    dispatch_q.enqueue("ORD-100002")
    print(f"Custom Queue Dispatch -> {dispatch_q.dequeue()}")

    builtin_q = deque(["ORD-100001", "ORD-100002"])
    print(f"Built-in deque Dispatch -> {builtin_q.popleft()}")

def min_coins_greedy(denominations, amount):
    denominations = sorted(denominations, reverse=True)
    result = []
    remaining = amount
    for coin in denominations:
        while remaining >= coin:
            remaining -= coin
            result.append(coin)
    return result if remaining == 0 else None


def min_coins_dp(denominations, amount):
    dp = [float("inf")] * (amount + 1)
    parent = [-1] * (amount + 1)
    dp[0] = 0

    for a in range(1, amount + 1):
        for coin in denominations:
            if a >= coin and dp[a - coin] + 1 < dp[a]:
                dp[a] = dp[a - coin] + 1
                parent[a] = coin

    if dp[amount] == float("inf"):
        return None

    coins_used = []
    curr = amount
    while curr > 0:
        coins_used.append(parent[curr])
        curr -= parent[curr]
    return coins_used


def run_task_5():
    print("\n--- TASK 5: Refund Change — Greedy vs Dynamic Programming ---")
    standard_denoms = [500, 200, 100, 50, 20, 10, 5, 2, 1]
    print(f"Standard Currency (₹780) Greedy: {min_coins_greedy(standard_denoms, 780)}")

    tricky_denoms = [1, 3, 4]
    refund = 6
    greedy_ans = min_coins_greedy(tricky_denoms, refund)
    dp_ans = min_coins_dp(tricky_denoms, refund)
    print(f"Counterexample Denominations {tricky_denoms}, Refund = {refund}:")
    print(f"  Greedy Result ({len(greedy_ans)} coins): {greedy_ans}  <-- Suboptimal!")
    print(f"  DP Result     ({len(dp_ans)} coins): {dp_ans}  <-- Optimal!")


if __name__ == "__main__":
    generate_orders_csv()
    orders_data = load_orders()
    run_task_1(orders_data)
    run_task_2(orders_data)
    run_task_3(orders_data)
    run_task_4()
    run_task_5()