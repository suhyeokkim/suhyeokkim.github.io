---
layout: post
author: "Su-Hyeok Kim"
comments: true
show: false
categories:
  - jekyll
  - makeblog
---

아는 지인이 좋다고 추천해서 jekyll+github 으로 블로그를 만들게 되었다.
한글로 된 자료가 그리 많지 않아 직접 기록해보려 한다.

### atom 에디터 설정하기

에디터 다운 받기~

[rubyinstaller-site]: https://rubyinstaller.org/

## 댓글 기능 붙이기

간단하다.

1. [disqus 홈페이지][disqus_home] 에 가입한다.
2. 가입할 때 만든 페이지 관리 창으로 간다.
3. Installing disqus 를 선택 후 jekyll 을 선택한다.
4. 포스팅 위의 header 정보에 "comments: true" 가 되어 있어야 댓글이 나온다.
5. 그 다음 Embeded Code 를 \_includes 폴더에 파일로 하나 만들어 둔다.
6. 그리고 post.html 에 \{\% include (파일이름) \%\} 이 코드를 원하는 곳에 넣어주면 작동한다.

[github_com]: https://github.com/
[jekyll-home]: https://jekyllrb.com/
[jekyll-kr]: https://jekyllrb-ko.github.io/
[jekyll-theme]: htpps://jekyllthemes.org/
[jekyll-whiteglass]: https://github.com/yous/whiteglass
[disqus_home]: https://disqus.com/


## travis-ci 설정하기
