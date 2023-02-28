CREATE PROCEDURE [dbo].[newcopiarusuario]
(
	@UsuDe varchar (8),
	@UsuPara varchar (max),
	@para varchar(max),
	@UniCod	tinyint = null
)
AS
if ((select 1 from Usuario where Usuario = @UsuDe) = 1 and
	(select 1 from Usuario where Usuario = @UsuPara) = 1)
BEGIN

	select *
	into #tmp_CopiaUsuarioUnidade
	from UsuarioUnidade
	where Usuario = @UsuDe
	and (@UniCod is null or unicod = @UniCod)
	
	DECLARE cursor1 cursor for 
	select value  FROM string_split (@UsuPara, ';') 
	open cursor1
		fetch next from cursor1 into @para
			while @@FETCH_STATUS = 0
				begin
					update #tmp_CopiaUsuarioUnidade
					set Usuario = @para
					where Usuario = @UsuDe
					fetch next from cursor1 into @para
			
				end 
				close cursor1;
				DEALLOCATE cursor1; 


	if exists (select 1 from UsuarioUnidade where Usuario = @UsuPara and (@UniCod is null or unicod = @UniCod))
		begin
			delete from UsuarioUnidade
			where Usuario = @UsuPara
			and (@UniCod is null or unicod = @UniCod)
		end

	insert into UsuarioUnidade 
	select * from #tmp_CopiaUsuarioUnidade

	drop table #tmp_CopiaUsuarioUnidade
	end
	else
	begin
		raiserror ( '[CopiaUsuarioUnidade] Usuário não cadastrado', 16, 1)
		return -1
end