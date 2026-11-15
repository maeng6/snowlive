import sys, os, math
sys.path.insert(0, os.environ['SP'])
import scene as S
from PIL import Image, ImageDraw, ImageFont

SP=os.environ['SP']; A='/Users/8choon/project/snowlive/assets/fonts'
GAL_B=A+'/Galmuri11-Bold.ttf'; GAL_R=A+'/Galmuri11.ttf'; PS=SP+'/PressStart2P-Regular.ttf'

BREAD=['...........nnn..','..........nggyn.','.........nggyocn','........nggyoocn',
       '.......ngcyyoocn','......nggcccocn.','.....ngcyyccccn.','....ngcccyoccn..',
       '...nggycccoccn..','..ngccyyccccn...','.nggyccooccn....','nggyycccccn.....',
       'ngyooocccn......','nyoooccnn.......','.ncccnn.........','..nnn...........']
BLEG={'n':S.NIGHT,'c':(0xA2,0x68,0x2E),'o':(0xD9,0x9B,0x45),'y':(0xEF,0xC8,0x77),'g':(0xF8,0xE1,0xA8)}
FLAG=['.n.......','.nrrrr...','.nrrrrr..','.nrrrr...','.n.......','.n.......','.n.......','.n.......','iiii.....']
FLEG={'n':S.NIGHT,'r':(0xC9,0x56,0x5F),'i':S.SH2}

def blit(im,grid,leg,x,y,sc):
    d=ImageDraw.Draw(im)
    for gy,row in enumerate(grid):
        for gx,ch in enumerate(row):
            if ch in leg:
                d.rectangle([x+gx*sc,y+gy*sc,x+(gx+1)*sc-1,y+(gy+1)*sc-1],fill=leg[ch])

def tw(f,t,sp):
    return sum(f.getlength(c)+sp for c in t)-sp if t else 0

def draw_sp(d,f,t,x,y,fill,sp):
    for c in t:
        d.text((x,y),c,font=f,fill=fill); x+=f.getlength(c)+sp

def outlined(im,f,t,cx,y,fill,ol,w):
    d=ImageDraw.Draw(im); x=cx-f.getlength(t)/2
    for dx in range(-w,w+1):
        for dy in range(-w,w+1):
            if dx or dy: d.text((x+dx,y+dy),t,font=f,fill=ol)
    d.text((x,y),t,font=f,fill=fill); return f.getbbox(t)[3]

def make(W,H,dot,ts,ss,p1,p2,pc,bsc,gaps,out):
    cols=math.ceil(W/dot); rows=math.ceil(H/dot)
    g0,g1,g2,g3=gaps
    fT=ImageFont.truetype(GAL_B,ts); fS=ImageFont.truetype(GAL_R,ss)
    f1=ImageFont.truetype(PS,p1);   f2=ImageFont.truetype(PS,p2); fC=ImageFont.truetype(PS,pc)
    L1='26/27 SEASON'; T='휘팍 개장빵 이벤트'; L2='PHOENIX PARK OPENING'
    SUB='스리X휘팍 26/27시즌 개장빵 이벤트!'; CH='2026.11.20 OPEN'
    hT=fT.getbbox(T)[3]; hS=fS.getbbox(SUB)[3]
    chH=int(pc*2.6); ow0=max(1,ts//11)
    blockH=p1+g0+max(hT,16*bsc)+ow0*2+g1+p2+g2+hS+g3+chH
    top=(H-blockH)//2
    cy=(top+blockH/2)/dot
    # 타원은 화면 비율이 아니라 **실제 글자 폭** 기준으로 잡는다. 화면 비율로
    # 잡으면 가로로 긴 PC 배너에서 숲이 통째로 날아간다.
    sp1_=max(2,p1//5); sp2_=max(3,p2//4)
    contentW=max(fT.getlength(T)+bsc*2+16*bsc,
                 fS.getlength(SUB), tw(f2,L2,sp2_), tw(f1,L1,sp1_))
    clear=S.Clear(cols/2, cy, (contentW/2+ts*0.75)/dot, (blockH/2+ts*0.60)/dot)
    im=S.build(cols,rows,clear,5).resize((cols*dot,rows*dot),Image.NEAREST).crop((0,0,W,H)).convert('RGB')
    d=ImageDraw.Draw(im); C=W//2; y=top
    sp1=max(2,p1//5); draw_sp(d,f1,L1,C-tw(f1,L1,sp1)/2,y,S.DEEPBLUE,sp1); y+=p1+g0
    bw=16*bsc; tWid=fT.getlength(T); total=tWid+bsc*2+bw
    tx=C-total/2
    ow=max(1,ts//11)
    for dx in range(-ow,ow+1):
        for dy in range(-ow,ow+1):
            if dx or dy: d.text((tx+dx,y+dy),T,font=fT,fill=S.SNOW)
    d.text((tx,y),T,font=fT,fill=S.NIGHT)
    blit(im,BREAD,BLEG,int(tx+tWid+bsc*2),int(y+(hT-bw)/2),bsc)
    y+=max(hT,bw)+ow*2+g1
    sp2=max(3,p2//4); draw_sp(d,f2,L2,C-tw(f2,L2,sp2)/2,y,S.DEEPBLUE,sp2); y+=p2+g2
    sx=C-fS.getlength(SUB)/2
    for dx in(-2,0,2):
        for dy in(-2,0,2):
            if dx or dy: d.text((sx+dx,y+dy),SUB,font=fS,fill=S.SNOW)
    d.text((sx,y),SUB,font=fS,fill=S.NIGHT); y+=hS+g3
    fsc=max(2,pc//5); fw=9*fsc; padx=int(pc*1.3); gapf=int(pc*0.7)
    cw=int(padx*2+fw+gapf+tw(fC,CH,max(1,pc//8))); bx=C-cw//2
    bd=max(2,pc//6)
    d.rectangle([bx,y,bx+cw,y+chH],fill=S.BLUE)
    d.rectangle([bx,y,bx+cw,y+chH],outline=S.NIGHT,width=bd)
    blit(im,FLAG,FLEG,bx+padx,int(y+(chH-9*fsc)/2),fsc)
    draw_sp(d,fC,CH,bx+padx+fw+gapf,y+(chH-pc)/2-pc*0.08,S.WHITE,max(1,pc//8))
    im.save(out); print(out, im.size)

make(3480,1044,6,110,55,28,24,26,7,(44,40,34,46), SP+'/hero_pc.png')
make(1080,1260,8, 77,33,20,18,20,5,(34,30,26,34), SP+'/hero_mobile.png')
make(1080,1350,8, 88,33,22,20,22,5,(40,34,30,40), SP+'/insta_4x5.png')
