
@testset "ilog2 $U(2^$e)" for e in (0, 7, 63, 64, 128, 200), U in (UInt8, UInt16, UInt32, UInt64, UInt128)
    
    a = U(2)^e
    @test iszero(a) || ilog2(a) == e
    @test iszero(a) || ilog2(a - 1) == e - 1
end 
 
@testset "ilog2 $U(2^$e)" for e in (0, 7, 63, 64, 128, 200), U in (Int8, Int16, Int32, Int64, Int128, BigInt)
    
    a = U(2)^e
    @test a <= 0 || ilog2(a) == e
    @test a <= 0 || ilog2(a - 1) == e - 1
    @test a <= 0 || ilog2(-a) == e
    @test a <= 0 || ilog2(-a + 1) == e - 1
end

@testset "ilog2 $U(0)" for U in (UInt8, UInt16, UInt32, UInt64, UInt128, BigInt)
    a = zero(U)
    @test ilog2(a) == -1
    @test ilog2(signed(a)) == - 1
end

 
