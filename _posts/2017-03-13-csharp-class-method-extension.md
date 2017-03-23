---
layout: post
author: "Su-hyeok Kim"
comments: true
show: true
tag: [csharp, c#]
---

unirx 를 살펴보다 모르는 문법이 나와서 기록해둔다. [MSDN 확장 메서드 문서](https://msdn.microsoft.com/ko-kr/library/bb383977.aspx) 를 참고했다.

## C# 클래스 확장 메서드

C# 3.0 문법부터 사용자가 기존에 정의된 클래스에 메소드를 확장 가능하게 되었다. obj-c 의 카테고리와 조금 비슷한것 같다. 자세한 사항은 코드와 함께 보자.

{% highlight csharp %}
using System.Linq;
using System.Text;
using System;

namespace CustomExtensions
{
    //Extension methods must be defined in a static class
    public static class StringExtension
       {
        // This is the extension method.
        // The first parameter takes the "this" modifier
        // and specifies the type for which the method is defined.
        public static int WordCount(this String str)
        {
            return str.Split(new char[] {' ', '.','?'}, StringSplitOptions.RemoveEmptyEntries).Length;
        }
    }
}
{% endhighlight %}

선언 방식은 위와 같다. 반드시 static class 에 static method 로 선언해주어야 하며, 첫번째 파라미터는 확장할 타겟 클래스의 인스턴스와 함께 앞에 this 키워드를 사용해주면 된다. 필요한 파라미터가 있다면 그 뒤에다 쭉 써주면 된다. 다만 외부에서 호출해주는 것이기 때문에 한정자의 제한을 받는다.

{% highlight csharp %}
namespace Extension_Methods_Simple
{
    //Import the extension method namespace.
    using CustomExtensions;
    class Program
    {
        static void Main(string[] args)
        {
            string s = "The quick brown fox jumped over the lazy dog.";
            //  Call the method as if it were an
            //  instance method on the type. Note that the first
            //  parameter is not specified by the calling code.
            int i = s.WordCount();
            System.Console.WriteLine("Word count of s is {0}", i);
        }
    }
}
{% endhighlight %}

사용 방법은 간단하다. 구현한 네임스페이스를 임포트 해주고, 확장한 메서드를 (인스턴스).(메서드) 형식으로 호출해주면 된다. 첫번째 타겟 클래스 인스턴스는 생략하고 파라미터를 넣어주면 된다. 다만 자기 자신의 함수를 호출해줄 때도 this 를 활용해 (인스턴스).(메서드) 형식으로 호출해주어야 한다.

## 주의점

이 기능은 참 편하다. 쉽게 클래스의 기능을 확장하기 때문이다. 근데 잘못 남용하다가는 아주 개판이 날 가능성이 높다. MSDN 에서는 반드시 필요한 곳에서만 사용하라고 권장하고 있다. 그리고 내 생각도 별반 다를바 없다.
