import random

# Cấu hình kích thước bài toán
NUM_CASES = 1000
M = 8  # Số hàng của ma trận A
N = 8  # Số cột của ma trận A (cũng là chiều dài vector X)

MIN_VAL = -32768
MAX_VAL = 32767
EDGE_VALUES = [MIN_VAL, MAX_VAL, 0, 1, -1]

def generate_element(specific_val=None):
    """10% rơi vào edge case, 90% random"""
    if specific_val is not None:
        return specific_val
    if random.random() < 0.1:
        return random.choice(EDGE_VALUES)
    return random.randint(MIN_VAL, MAX_VAL)

with open("Mat_vec_mul.txt", "w") as f:
    for t in range(NUM_CASES):
        # 5 Testcase đầu tiên là Edge Cases
        specific_val = None
        if t == 0: specific_val = 0          # Toàn 0
        elif t == 1: specific_val = 1        # Toàn 1
        elif t == 2: specific_val = -1       # Toàn -1
        elif t == 3: specific_val = MAX_VAL  # Max dương
        elif t == 4: specific_val = MIN_VAL  # Min âm
        
        # 1. Sinh Ma trận A cỡ M x N
        A = []
        for i in range(M):
            row = [generate_element(specific_val) for _ in range(N)]
            A.append(row)
            
        # 2. Sinh Vector X cỡ N x 1
        X = [generate_element(specific_val) for _ in range(N)]
        
        # 3. Tính toán Vector kết quả Y cỡ M x 1 (Y = A * X)
        Y = [0] * M
        for i in range(M):
            for j in range(N):
                Y[i] += A[i][j] * X[j]
                
        # 4. Ghi ra file text
        # M dòng, mỗi dòng N số (Ma trận A)
        for row in A:
            f.write(" ".join(map(str, row)) + "\n")
            
        # 1 dòng, N số (Vector X)
        f.write(" ".join(map(str, X)) + "\n")
        
        # 1 dòng, M số (Vector Y - Golden Output)
        f.write(" ".join(map(str, Y)) + "\n")
        f.write("\n")

print("Đã tạo thành công file 'Mat_vec_mul.txt'!")