#import <Kiwi/Kiwi.h>
#import "NSString+KeySigning.h"

SPEC_BEGIN(NSStringKeySigningSpec)

describe(@"NSString+KeySigning", ^{
    
    NSString *privateKeyString = @"-----BEGIN RSA PRIVATE KEY-----\nProc-Type: 4,ENCRYPTED\nDEK-Info: AES-128-CBC,CECC60BF4293C7A1A924265CC6EAC115\n\nKAwSbUVOXVou7j0OPJIgT1IXmOnUY/FsvL+vQc6GZT7M3FVEn36h+TB0bok1DC3D\nNN/PkzSdW3dhlkNLVmpRTis9ECih6I7Zpg1jEt0H/qE3Clz+5+sg44QcYe5RzUj5\n3E4dwujrNuds5HJaxN4T7SdAdxIIgVWuWlBqe9f2ZVJXoB9ndWIE23Vi17chwyQj\nWx0wLBUlMRPYdUI0OpCPKJIppf09HiRA9o4pKvlPfOJHSnPHepZmvKlKaHtiL7Hb\nilyEI82L7vvV44hYIZM0d4kZgfzFRAeZIkVql+Fj8tOxN47/q3O/4w4n50pqNFEF\nqSqCO5emobb1YkHOqfhb/H54OMxlqVpLTMhjl6rHR/kAa0ELSLLHGy8/VVHCTbpy\n+tkSl+LqJ04ErbY8gN0dVLFsjc04pha1Za2J9ccGTRDoOiNy+EQqDRGz+ewN8cxq\n/OHfXdRJEBWyo6QI4+Xd9SzTpCz9bifH0Wp+oI17CIOSNwdqCGNyb0hTOUne9Ktz\nc9JYXvfodeZMIQnoNtVTM1esDLu3+Mf/8ZuWdxryfcBgLofen4Ezp2K2+be60j15\nD3azqkE/Eq1r20JS6u2TS9aA5tyEq++RfxG+6EDj7i6ydl51BRzqbDWJNdn/NzWl\nWPsbLyo++7I9IWH3LWBAqijAKinAXygVGy3gPwerkz7icURJI6o2P2sOxZeZuPdw\nNDpzPE5Oj2xcWGbSousFmlMCuvJcGbNHOlfQZMEdGesxpqybMdefkEVjRinF+WLL\n1bdO/BS7jlrzCgy+j1Fdx8jzUb0QwGKKQIGkDwo25lC7b0cTDd3hjSTmoqJjpmWD\n3xg0wxEhE9zKD8M5aWtpWccj/PtVeH0eFor1frp8ZFVHlrzwWsgkPwK0Dt9W7PSk\nxDRcujg/t8pQNP9ToyCX8UHoId1WFpw0C2fQzqQhV0JuRnSzoGl8ovZZ+kV1Fu1T\nP/Q3Z4SMkY9ziOs+0yZMdjASroCmdWpSKD1FDn3PCk0PrtKrlw/rdWFxzQbG1FHY\nlo8eX1RmGSfmRTRTRzz0HzqI8bUvtfY0aJf/vCrksd/Of84zI5fl+6A4E0rI/UxX\nggwCoyHA8PEsUn5bRxWsAa6aBCOo3rRJmJYLL3f/77GWzUlRfdvLaFDzTRVwazfa\nSg6LKQRtwIIcezRHBJgFqgMo/FzzyTBdKujQMpS3crN6pA5lrYX8Aqqg827ddMBC\nyqO0ZPGot0vdHQjK0zQQxWZDPA3ozOwY+DxpuUvYiTUPBbUP2ps2CWS08zkN9hNL\nxYypuYgm3ozFVP35MYCwOVe2XlFptWvLURzs3j+c7PDv/Qgsrm43DdSP4/PqBg3q\niB33hTT5w1CEf6DZI1y8q9rrYBnZfQq+D0ee2NU34XnTtPvNi5+Id7eR2IUsJAzb\ntQ8KeHC9kumfIUNa9MqS/i2zc0YTKO6jzow4PD7t4wJxZKspMx/I19Lp3R8Yi7A6\nM76mudG9MXk7/sFX0hH4QGBliVv3Cy+0i8Z2ZzkEumQr+CYE9bT1heBj3qjlhgaF\nHBIS1w2kpXQChw8vgOxGJHzThc77hOEHramCCwQlh9MNecvOSV0C9S7CQ2vGMNda\n-----END RSA PRIVATE KEY-----\n";
    
    NSString *expected = @"fQjETWgIMqXEhNyJ52VdsZJIuXX+RHXO4wT5sFtMJBUMTpidksZ8NaQ3Fp1N\nYy2mJEee7Y835IOuFrGpkRroZWnO6s+jvTfWCmaK4DkRKVOB3DbS/o37+PA1\naGVHr7lKh0HHPk6tv7chxUbcdNKC+AWR5/m2DxehhAl23tdyDK2qPr0u2HLv\nzgHNnR4TQafjGOKVAekLdTLu0CUfd8fdzpUEJK5TdUkd6rA5zoORjsLOZXY/\n7cbanCzs2nNii9onJJov8SvbzLZ7e2Pq36Gum6AubZAEh0TMM7LRUQPDbogq\n69ZyXGD+eeuw9eZGkxiTd0ti3EFT9+OYpNnFRh/KAg==\n";
    
    NSString *result = [@"password" signWithPrivateKey:[privateKeyString dataUsingEncoding:NSUTF8StringEncoding]
                                            passphrase:@"727f38dc36b85a68d6bcdd7a7168e0ea3dda10c921117c8b796d7dec9dd1078c"];
    
    [[result should] equal:expected];
});

SPEC_END
