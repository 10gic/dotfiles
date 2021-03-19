#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import re
import argparse

parser = argparse.ArgumentParser(description='A tool can adjust input file to jpdfbookmarks bookmark.')
parser.add_argument('--input', default='bookmark.txt',
                    help='input file (default: bookmark.txt)')
parser.add_argument('--offset', default=0, type=int,
                    help='the page number offset (default: 0)')
parser.add_argument('--output', default='final_bookmark.txt',
                    help='output file (default: final_bookmark.txt)')
args = parser.parse_args()

pageNumDelta = args.offset
inputBookmark = args.input
outputBookmark = args.output

# Change input to jpdfbookmarks recognized format, for example:
# change '1.1 xxx1' to '\t1.1 xxx/1'
# change '1.1.1 xxx3' to '\t\t1.1.1 xxx/3'
# change '1.1 xxx/12,Black,notBold,notItalic,open,TopLeftZoom,1,0,0.0' to '\t1.1 xxx/12'
def adjustLine(line: str, pageNumDelta: int) -> str:
    line = line.replace(",Black,notBold,notItalic,open,TopLeftZoom,1,0,0.0", "")
    line = line.replace("　", " ")
    ret = ""
    searchObj = re.search(r'([\d.]*)(.*?)(\d*)$', line)
    if searchObj:
        sectionNum = searchObj.group(1)
        title = searchObj.group(2)
        pageNum = searchObj.group(3)
        if sectionNum:
            dotCount = sectionNum.count('.')
            ret += '\t' * dotCount + sectionNum + " "
        if title.endswith("/"):
            ret += title.strip()
        else:
            ret += title.strip() + "/"
        if pageNum:
            finalPageNum = int(pageNum) + pageNumDelta
            ret += str(finalPageNum)
    return ret


lines = []

with open(inputBookmark) as fp:
   for cnt, line in enumerate(fp):
       if line.strip():
           outline = adjustLine(line.strip(), pageNumDelta)
           lines.append(outline)

with open(outputBookmark, "w") as fp:
    fp.write('\n'.join(lines))

# bookmark.txt can be dump by following command:
# jpdfbookmarks input.pdf --dump -o bookmark.txt

print("{0} is generated, please run:".format(outputBookmark))
print("jpdfbookmarks input.pdf --apply {0} -o output.pdf".format(outputBookmark))
