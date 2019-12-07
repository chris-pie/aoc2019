program main
  implicit none
  integer :: fsize, re_i, numc, inspoint, input_v, temp, opcode, var1, var1o, var2, var3, resulto, out_add
  integer, dimension(:), allocatable :: mem
  character(len=:), allocatable :: mystr
  input_v = 5
  inspoint = 0
  inquire(FILE='day 5.txt', size=fsize)
  allocate(character(fsize) :: mystr)
  open (69, file='day 5.txt')
  read(69, '(A)') mystr
  numc = countsubstring(mystr, ",")
  allocate (mem(numc + 1))
  rewind 69
  read(69, *) mem
  do while (mem(inspoint + 1) .ne. 99)
    resulto = mem(1)
    out_add = 1
    temp = mem(inspoint + 1)
    opcode = modulo(temp, 100)
    temp = temp / 100
    var1 = getVarByMode(mem,modulo(temp, 10),mem(inspoint + 2))
    var1o = mem(inspoint + 2)
    temp = temp / 10
    var2 = getVarByMode(mem,modulo(temp, 10),mem(inspoint + 3))
    temp = temp / 10
    var3 = mem(inspoint + 4)
    select case (opcode)
        case (1)
            resulto = var1 + var2
            out_add = var3
            inspoint = inspoint + 4
        case (2)
            resulto = var1 * var2
            out_add = var3
            inspoint = inspoint + 4
        case (3)
            resulto = input_v
            out_add = var1o
            inspoint = inspoint + 2
        case (4)
            write(*,*) var1
            inspoint = inspoint + 2
        case (5)
            if (var1 .ne. 0) then
                inspoint = var2
            else
                inspoint = inspoint + 3
            end if
        case (6)
            if (var1 .eq. 0) then
                inspoint = var2
            else
                inspoint = inspoint + 3
            end if
        case (7)
            if (var1 .lt. var2) then
                resulto = 1
            else
                resulto = 0
            end if
            out_add = var3
            inspoint = inspoint + 4
        case (8)
            if (var1 .eq. var2) then
                resulto = 1
            else
                resulto = 0
            end if
            out_add = var3
            inspoint = inspoint + 4
        case default
            write(*,*) "ERROR"



    end select
    mem(out_add + 1) = resulto



  end do
  re_i = system("pause")





contains

  function getVarByMode(mem, mode, num) result(r)
    integer, intent(in) :: mode, num
    integer :: r
    integer, dimension(:), intent(in) :: mem
    if(mode == 1) then
        r = num
    else
        r = mem(num + 1)
    end if
    return
  end function

  function countsubstring(s1, s2) result(c)
      character(*), intent(in) :: s1, s2
      integer :: c, p, posn

      c = 0
      if(len(s2) == 0) return
      p = 1
      do
        posn = index(s1(p:), s2)
        if(posn == 0) return
        c = c + 1
        p = p + posn + len(s2)
      end do
    end function
endprogram
