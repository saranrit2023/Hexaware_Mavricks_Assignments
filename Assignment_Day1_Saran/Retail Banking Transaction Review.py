import random
import time
from datetime import datetime, timedelta

def binary_search_with_count(sorted_ids, target):
    low, high = 0, len(sorted_ids) - 1
    comparisons = 0
    while low <= high:
        mid = (low + high) // 2
        comparisons += 1
        if sorted_ids[mid] == target:
            return mid, comparisons
        elif sorted_ids[mid] < target:
            low = mid + 1
        else:
            high = mid - 1
    return -1, comparisons


def linear_search_with_count(ids, target):
    comparisons = 0
    for idx, val in enumerate(ids):
        comparisons += 1
        if val == target:
            return idx, comparisons
    return -1, comparisons


def run_task_1():
    print("\n--- SET 2 | TASK 1: Search Comparisons (100,000 Transaction IDs) ---")
    tx_ids = [f"TXN-{1000000 + i}" for i in range(100000)]

    best_target = tx_ids[(len(tx_ids) - 1) // 2]  
    avg_target = tx_ids[37123]
    worst_target = "TXN-9999999"                   

    for label, target in [("Best Case", best_target), ("Average Case", avg_target), ("Worst Case", worst_target)]:
        _, b_comp = binary_search_with_count(tx_ids, target)
        _, l_comp = linear_search_with_count(tx_ids, target)
        print(f"{label:12} -> Binary Search: {b_comp:2} comparisons | Linear Search: {l_comp:6} comparisons")


def insertion_sort_txns(txns):
    arr = txns[:]
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        while j >= 0 and arr[j]["timestamp"] > key["timestamp"]:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key
    return arr


def merge_sort_txns(txns):
    if len(txns) <= 1:
        return txns
    mid = len(txns) // 2
    left = merge_sort_txns(txns[:mid])
    right = merge_sort_txns(txns[mid:])
    return _merge_stable(left, right)


def _merge_stable(left, right):
    merged = []
    i = j = 0
    while i < len(left) and j < len(right):
        if left[i]["timestamp"] <= right[j]["timestamp"]:
            merged.append(left[i])
            i += 1
        else:
            merged.append(right[j])
            j += 1
    merged.extend(left[i:])
    merged.extend(right[j:])
    return merged


def run_task_2():
    print("\n--- SET 2 | TASK 2: Sorting & Stability Demonstration ---")
    sample_statement = [
        {"id": "T1", "timestamp": "2026-10-14 10:05:00", "desc": "Salary Credit (+5000)", "seq": 1},
        {"id": "T2", "timestamp": "2026-10-14 10:05:00", "desc": "Rent Auto-Debit (-4500)", "seq": 2},
        {"id": "T3", "timestamp": "2026-10-14 09:30:00", "desc": "Coffee Shop (-150)", "seq": 3},
    ]
    print("Insertion Sort:", [(t["id"], t["desc"]) for t in insertion_sort_txns(sample_statement)])
    print("Merge Sort    :", [(t["id"], t["desc"]) for t in merge_sort_txns(sample_statement)])
    print("Why Stability Matters: T1 (Credit) happened before T2 (Debit) at 10:05:00. A stable sort keeps T1 before T2 so the running balance never falsely goes negative.")

def find_duplicate_postings(transactions):
    history = {}
    duplicates = []
    for tx in transactions:
        key = (tx["account"], tx["amount"], tx["merchant"])
        ts = datetime.strptime(tx["timestamp"], "%Y-%m-%d %H:%M:%S").timestamp()
        if key in history:
            for prev_ts, prev_id in history[key]:
                if abs(ts - prev_ts) <= 60:
                    duplicates.append((prev_id, tx["id"], key))
                    break
            history[key].append((ts, tx["id"]))
        else:
            history[key] = [(ts, tx["id"])]
    return duplicates


def run_task_3():
    print("\n--- SET 2 | TASK 3: Duplicate Postings Within 60 Seconds ---")
    txns = [
        {"id": "TX-1", "account": "ACC-901", "amount": 250.0, "merchant": "Amazon", "timestamp": "2026-10-14 11:00:50"},
        {"id": "TX-2", "account": "ACC-901", "amount": 250.0, "merchant": "Amazon", "timestamp": "2026-10-14 11:01:25"},  # 35s later -> Duplicate!
        {"id": "TX-3", "account": "ACC-901", "amount": 250.0, "merchant": "Amazon", "timestamp": "2026-10-14 11:05:00"},  # >60s -> Valid
    ]
    print("Flagged Duplicates:", find_duplicate_postings(txns))


class Node:
    def __init__(self, data):
        self.data = data
        self.next = None


class ManualReviewQueue:
    def __init__(self):
        self.front = self.rear = None

    def enqueue(self, item):
        node = Node(item)
        if not self.rear:
            self.front = self.rear = node
            return
        self.rear.next = node
        self.rear = node

    def dequeue(self):
        if not self.front:
            raise IndexError("Queue is empty")
        val = self.front.data
        self.front = self.front.next
        if not self.front:
            self.rear = None
        return val


class AdjustmentStack:
    def __init__(self):
        self.top = None

    def push(self, item):
        node = Node(item)
        node.next = self.top
        self.top = node

    def pop(self):
        if not self.top:
            raise IndexError("Stack is empty")
        val = self.top.data
        self.top = self.top.next
        return val


def run_task_4():
    print("\n--- SET 2 | TASK 4: Custom FIFO Queue & LIFO Stack ---")
    q = ManualReviewQueue()
    q.enqueue("Case-101 (Flagged Wire)")
    q.enqueue("Case-102 (Card Dispute)")
    print("Next Review (FIFO):", q.dequeue())

    s = AdjustmentStack()
    s.push("Adj-1: Waived Fee ₹500")
    s.push("Adj-2: Credited Interest ₹120")
    print("Reversed Adjustment (LIFO):", s.pop())

def minmax_divide_and_conquer(arr, low, high):
    if low == high:
        return arr[low], arr[low], 0
    if high == low + 1:
        if arr[low] < arr[high]:
            return arr[low], arr[high], 1
        return arr[high], arr[low], 1

    mid = (low + high) // 2
    min1, max1, c1 = minmax_divide_and_conquer(arr, low, mid)
    min2, max2, c2 = minmax_divide_and_conquer(arr, mid + 1, high)
    return min(min1, min2), max(max1, max2), c1 + c2 + 2


def minmax_brute_force(arr):
    lo = hi = arr[0]
    comps = 0
    for x in arr[1:]:
        comps += 1
        if x < lo:
            lo = x
        comps += 1
        if x > hi:
            hi = x
    return lo, hi, comps


def run_task_5():
    print("\n--- SET 2 | TASK 5: Divide-and-Conquer Min/Max vs. Brute Force ---")
    amounts = [round(random.uniform(5.0, 99999.0), 2) for _ in range(10000)]
    dc_min, dc_max, dc_comps = minmax_divide_and_conquer(amounts, 0, len(amounts) - 1)
    bf_min, bf_max, bf_comps = minmax_brute_force(amounts)
    print(f"Divide & Conquer -> Min: {dc_min}, Max: {dc_max} | Comparisons: {dc_comps}")
    print(f"Brute Force Scan -> Min: {bf_min}, Max: {bf_max} | Comparisons: {bf_comps}")


if __name__ == "__main__":
    run_task_1()
    run_task_2()
    run_task_3()
    run_task_4()
    run_task_5()