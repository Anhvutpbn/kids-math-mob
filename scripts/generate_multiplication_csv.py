"""
Tạo CSV câu hỏi bảng cửu chương với text TTS rõ ràng.
Dùng làm tài liệu tham khảo hoặc seed cho question bank.

Run: python scripts/generate_multiplication_csv.py
Output: scripts/multiplication_questions.csv
"""

import csv
import os

rows = []

for a in range(1, 11):
    for b in range(1, 10):
        result = a * b

        # Type 1: a × b = ?   (missing result)
        rows.append({
            'type': 'missing_result',
            'a': a,
            'b': b,
            'result': result,
            'display': f'{a} × {b} = ?',
            'tts_vi': f'{a} nhân {b} bằng bao nhiêu?',
            'level': 'basic' if a <= 5 else 'medium',
        })

        # Type 2: ? × b = result  (missing left)
        rows.append({
            'type': 'missing_left',
            'a': a,
            'b': b,
            'result': result,
            'display': f'? × {b} = {result}',
            'tts_vi': f'Bao nhiêu nhân {b} bằng {result}?',
            'level': 'basic' if a <= 5 else 'medium',
        })

        # Type 3: a × ? = result  (missing right)
        rows.append({
            'type': 'missing_right',
            'a': a,
            'b': b,
            'result': result,
            'display': f'{a} × ? = {result}',
            'tts_vi': f'{a} nhân bao nhiêu bằng {result}?',
            'level': 'basic' if a <= 5 else 'medium',
        })

output_path = os.path.join(os.path.dirname(__file__), 'multiplication_questions.csv')
with open(output_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['type', 'a', 'b', 'result', 'display', 'tts_vi', 'level'])
    writer.writeheader()
    writer.writerows(rows)

print(f'Generated {len(rows)} questions -> {output_path}')
print('Vi du:')
for r in rows[:6]:
    print(f"  [{r['type']}] {r['display']}  TTS: \"{r['tts_vi']}\"")
