import random
import time


def linear_search_patient(records, pid):
    for rec in records:
        if rec["patientId"] == pid:
            return rec
    return None


def binary_search_patient(sorted_records, pid):
    low, high = 0, len(sorted_records) - 1
    while low <= high:
        mid = (low + high) // 2
        if sorted_records[mid]["patientId"] == pid:
            return sorted_records[mid]
        elif sorted_records[mid]["patientId"] < pid:
            low = mid + 1
        else:
            high = mid - 1
    return None


def run_task_1():
    print("\n--- SET 3 | TASK 1: 1,000 Lookups Over 20,000 Patient Records ---")
    patients = [{"patientId": f"PAT-{10000 + i}", "name": f"Patient {i}"} for i in range(20000)]
    queries = [random.choice(patients)["patientId"] for _ in range(1000)]

    t0 = time.perf_counter()
    for q in queries:
        linear_search_patient(patients, q)
    t_lin = (time.perf_counter() - t0) * 1000

    t0 = time.perf_counter()
    for q in queries:
        binary_search_patient(patients, q)
    t_bin = (time.perf_counter() - t0) * 1000

    print(f"Linear Search (1,000 lookups): {t_lin:.2f} ms")
    print(f"Binary Search (1,000 lookups): {t_bin:.2f} ms")

def selection_sort_appointments(appts):
    arr = appts[:]
    n = len(arr)
    swaps = 0
    for i in range(n):
        min_idx = i
        for j in range(i + 1, n):
            key_j = (arr[j]["urgency"], arr[j]["arrival"])
            key_min = (arr[min_idx]["urgency"], arr[min_idx]["arrival"])
            if key_j < key_min:
                min_idx = j
        if min_idx != i:
            arr[i], arr[min_idx] = arr[min_idx], arr[i]
            swaps += 1
    return arr, swaps


def quick_sort_appointments(appts):
    arr = appts[:]
    swaps = [0]

    def _qs(low, high):
        if low < high:
            p = _partition(low, high)
            _qs(low, p - 1)
            _qs(p + 1, high)

    def _partition(low, high):
        pivot = (arr[high]["urgency"], arr[high]["arrival"])
        i = low - 1
        for j in range(low, high):
            if (arr[j]["urgency"], arr[j]["arrival"]) <= pivot:
                i += 1
                if i != j:
                    arr[i], arr[j] = arr[j], arr[i]
                    swaps[0] += 1
        if i + 1 != high:
            arr[i + 1], arr[high] = arr[high], arr[i + 1]
            swaps[0] += 1
        return i + 1

    _qs(0, len(arr) - 1)
    return arr, swaps[0]


def run_task_2():
    print("\n--- SET 3 | TASK 2: Selection Sort vs. Quick Sort (Swaps & Time) ---")
    roster = [
        {"id": f"A-{i}", "urgency": random.randint(1, 5), "arrival": f"{random.randint(8,17):02d}:{random.randint(0,59):02d}"}
        for i in range(2000)
    ]
    t0 = time.perf_counter()
    _, sel_swaps = selection_sort_appointments(roster)
    t_sel = (time.perf_counter() - t0) * 1000

    t0 = time.perf_counter()
    _, qs_swaps = quick_sort_appointments(roster)
    t_qs = (time.perf_counter() - t0) * 1000

    print(f"Selection Sort -> Swaps: {sel_swaps:5} | Time: {t_sel:.2f} ms")
    print(f"Quick Sort     -> Swaps: {qs_swaps:5} | Time: {t_qs:.2f} ms")

class AppointmentScheduler:
    def __init__(self):
        self.booked_pairs = set()  

    def book(self, patient_id, slot):
        key = (patient_id, slot)
        if key in self.booked_pairs:
            return False, f"REJECTED: {patient_id} is already booked at {slot}"
        self.booked_pairs.add(key)
        return True, f"CONFIRMED: {patient_id} booked at {slot}"


def run_task_3():
    print("\n--- SET 3 | TASK 3: Double-Booking Detection ---")
    sched = AppointmentScheduler()
    print(sched.book("PAT-1001", "10:00 AM"))
    print(sched.book("PAT-1002", "10:00 AM"))
    print(sched.book("PAT-1001", "10:00 AM"))  

class Node:
    def __init__(self, val):
        self.val = val
        self.next = None


class TokenQueue:
    def __init__(self):
        self.head = self.tail = None

    def enqueue(self, token):
        n = Node(token)
        if self.tail:
            self.tail.next = n
        self.tail = n
        if not self.head:
            self.head = n

    def dequeue(self):
        if not self.head:
            raise IndexError("No tokens waiting")
        val = self.head.val
        self.head = self.head.next
        if not self.head:
            self.tail = None
        return val


class RecentPatientsStack:
    def __init__(self):
        self.top = None

    def push(self, patient):
        n = Node(patient)
        n.next = self.top
        self.top = n

    def pop(self):
        if not self.top:
            raise IndexError("No recent history")
        val = self.top.val
        self.top = self.top.next
        return val


def run_task_4():
    print("\n--- SET 3 | TASK 4: Walk-in Queue & Recent History Stack ---")
    tokens = TokenQueue()
    tokens.enqueue("Token #1 (PAT-1001)")
    tokens.enqueue("Token #2 (PAT-1005)")
    print("Called Next Patient (FIFO):", tokens.dequeue())

    recent = RecentPatientsStack()
    recent.push("Viewed: PAT-1001")
    recent.push("Viewed: PAT-1009")
    print("Back to Last Viewed (LIFO):", recent.pop())


def max_appointments_dp(intervals):

    sorted_iv = sorted(intervals, key=lambda x: x[1])
    n = len(sorted_iv)
    p = [-1] * n
    for i in range(n):
        for j in range(i - 1, -1, -1):
            if sorted_iv[j][1] <= sorted_iv[i][0]:
                p[i] = j
                break

    dp = [0] * (n + 1)
    for i in range(1, n + 1):
        incl = 1 + (dp[p[i - 1] + 1] if p[i - 1] != -1 else 0)
        excl = dp[i - 1]
        dp[i] = max(incl, excl)
    return dp[n]


def greedy_by_earliest_start(intervals):
    sorted_iv = sorted(intervals, key=lambda x: x[0])
    chosen = []
    last_end = -1
    for iv in sorted_iv:
        if iv[0] >= last_end:
            chosen.append(iv)
            last_end = iv[1]
    return len(chosen), chosen


def run_task_5():
    print("\n--- SET 3 | TASK 5: Shift Scheduling — DP vs. Greedy ---")
    shift_slots = [
        (9, 13, "Full-Morning Surgery (4h)"),
        (9, 10, "Consult A (1h)"),
        (10, 11, "Consult B (1h)"),
        (11, 12, "Consult C (1h)"),
        (12, 13, "Consult D (1h)"),
    ]
    g_count, g_list = greedy_by_earliest_start(shift_slots)
    dp_count = max_appointments_dp(shift_slots)
    print(f"Greedy (Earliest Start): {g_count} appointment -> {[x[2] for x in g_list]}")
    print(f"Dynamic Programming    : {dp_count} appointments (Optimal!)")


if __name__ == "__main__":
    run_task_1()
    run_task_2()
    run_task_3()
    run_task_4()
    run_task_5()