import pandas as pd
from googletrans import Translator
from tqdm import tqdm
import openpyxl

t = Translator()

df = pd.read_excel(r"C:\Users\btk-sgt-005\Desktop\KRE_projekt-main\ekezetes.xlsx", header=None)
df.dropna(inplace=True)
df.rename({0: "text"}, axis=1, inplace=True)

translated = []
# max = int(df.shape[0]/10)
max = 10
with tqdm(total=max) as bar:
    # with open("translated.csv", "w", encoding="UTF-8") as csv:
    #     csv.writelines("translated_text")
    for r in df["text"][:max]:
        text = r.lower().replace(" h ", " hogy ")
        t_text = t.translate(text, dest="en").text
        t_text = t_text.replace("\n", " ")
        translated.append(t_text)
        bar.update(1)

translated = pd.DataFrame({"original": df.loc[:max-1, "text"], "translated": translated})
translated.to_csv("translated.csv", "\t")


