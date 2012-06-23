package hxop.ops;
import hxs.Signal;
import hxs.Signal1;
import hxs.Signal2;

class HxsOps
{
	@op("+=") static public function add0(lhs:Signal, rhs:Void->Void)
	{
		lhs.add(rhs);
		return lhs;
	}
	
	@op("+=") static public function add1<T>(lhs:Signal1<T>, rhs:T->Void)
	{
		lhs.add(rhs);
		return lhs;
	}
	
	@op("+=") static public function add2<T1, T2>(lhs:Signal2<T1, T2>, rhs:T1->T2->Void)
	{
		lhs.add(rhs);
		return lhs;
	}		
}