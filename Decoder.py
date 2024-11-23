import tkinter as tk
from tkinter import filedialog, messagebox
import re

def create_gui():
    global text_area
    window = tk.Tk()
    window.title("Decodificador Assembly a Binario")
    window.geometry("800x600")
    window.configure(bg="#f0f0f5")

    # Título principal
    title_label = tk.Label(
        window, 
        text="Decodificador Assembly a Binario",
        font=("Helvetica", 16, "bold"),
        bg="#f0f0f5"
    )
    title_label.pack(pady=10)

    # Botones
    button_frame = tk.Frame(window, bg="#f0f0f5")
    button_frame.pack(pady=20)

    import_button = tk.Button(
        button_frame,
        text="Importar archivo .asm",
        command=import_file,
        font=("Helvetica", 12),
        bg="#d0d0ff",
        fg="#000000"
    )
    import_button.grid(row=0, column=0, padx=10)

    decode_button = tk.Button(
        button_frame,
        text="Decodificar",
        command=analyze_text,
        font=("Helvetica", 12),
        bg="#d0ffd0",
        fg="#000000"
    )
    decode_button.grid(row=0, column=1, padx=10)

    save_button = tk.Button(
        button_frame,
        text="Guardar archivo .txt",
        command=save_file,
        font=("Helvetica", 12),
        bg="#ffd0d0",
        fg="#000000"
    )
    save_button.grid(row=0, column=2, padx=10)

    # Área de texto
    text_area = tk.Text(window, wrap=tk.WORD, height=25, width=90, font=("Courier", 10))
    text_area.pack(pady=10)

    window.mainloop()

def import_file():
    file_path = filedialog.askopenfilename(
        filetypes=[("Archivos Assembly", "*.asm")],
        title="Selecciona un archivo"
    )
    if file_path:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
            text_area.delete("1.0", tk.END)
            text_area.insert(tk.END, content)
        global current_file
        current_file = file_path

def analyze_text():
    content = text_area.get("1.0", tk.END)
    lines = content.strip().split("\n")
    decoded_lines = []

    for line in lines:
        try:
            decoded_line = ensambladorAbinario(line)
            decoded_lines.append(decoded_line)
        except Exception as e:
            decoded_lines.append(f"Error al procesar: {line} ({e})")

    text_area.delete("1.0", tk.END)
    text_area.insert(tk.END, "\n".join(decoded_lines))

def ensambladorAbinario(instruccionEnsamblador):
    # Operaciones para tipo R
    operaciones_tipo_r = {
        'ADD': '100000',
        'SUB': '100010',
        'AND': '100100',
        'OR': '100101',
        'SLT': '101010'
    }
    # Operaciones para tipo I
    operaciones_tipo_i = {
        'ADDI': '001000',
        'SUBI': '001001',
        'ORI': '001101',
        'ANDI': '001100',
        'SLTI': '001010',
        'LW': '100011',
        'SW': '101011'
    }
    # Operaciones para branch
    operaciones_branch = {
        'BEQ': '000100'
    }
    # Registros (del $0 al $31)
    registros = {f"${i}": f"{i:05b}" for i in range(32)}

    # Dividir la instrucción en partes
    partes = instruccionEnsamblador.split()
    operacion = partes[0]

    # Decodificación tipo R
    if operacion in operaciones_tipo_r:
        opcode = "000000"  # Tipo R siempre tiene opcode 0
        rs = registros[partes[2]]
        rt = registros[partes[3]]
        rd = registros[partes[1]]
        shamt = "00000"  # Desplazamiento (no usado en estas operaciones)
        funct = operaciones_tipo_r[operacion]
        return f"{opcode}{rs}{rt}{rd}{shamt}{funct}"

    # Decodificación tipo I (ADDI, SUBI, ORI, ANDI, SLTI)
    elif operacion in operaciones_tipo_i and operacion not in ["LW", "SW"]:
        opcode = operaciones_tipo_i[operacion]
        rt = registros[partes[1]]
        rs = registros[partes[2]]
        imm = f"{int(partes[3]):016b}"  # Inmediato de 16 bits
        return f"{opcode}{rs}{rt}{imm}"

    # Decodificación tipo I (LW, SW con offset(base))
    elif operacion in ["LW", "SW"]:
        opcode = operaciones_tipo_i[operacion]
        rt = registros[partes[1]]
        offset, base = partes[2].split('(')  # Separar offset y base
        rs = registros[base.strip(')')]  # Eliminar paréntesis
        imm = f"{int(offset):016b}"  # Offset como inmediato de 16 bits
        return f"{opcode}{rs}{rt}{imm}"

    # Decodificación para branch (BEQ)
    elif operacion in operaciones_branch:
        opcode = operaciones_branch[operacion]
        rs = registros[partes[1]]
        rt = registros[partes[2]]
        imm = f"{int(partes[3]):016b}"  # Inmediato de 16 bits (desplazamiento)
        return f"{opcode}{rs}{rt}{imm}"

    # Si no es reconocida
    raise ValueError(f"Operación no reconocida: {operacion}")



def save_file():
    file_path = filedialog.asksaveasfilename(
        defaultextension=".txt",
        filetypes=[("Archivos de texto", "*.txt")],
        title="Guardar archivo como"
    )
    if file_path:
        with open(file_path, "w", encoding="utf-8") as f:
            content = text_area.get("1.0", tk.END)
            f.write(content.strip())
        messagebox.showinfo("Éxito", "Archivo guardado correctamente.")

create_gui()
